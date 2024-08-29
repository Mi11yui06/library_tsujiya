class CountersController < ApplicationController
  before_action :require_logged_in
  def new #new画面用
    @member = Member.find_by(id: params[:member_id])
    if @member
      @loans = @member.loans.where(return_date: nil)
      @return_loans = @member.loans.where(return_date: nil)
      @unreturned_count = @return_loans.count
      @loan = Loan.new
      @loan_date = params[:loan_date] || Date.today
      @stock_ids = params[:stock_ids] || []
    else
      flash[:danger] = "会員が見つかりません。"
      redirect_to root_path
    end
  end

  def confirm_return #new画面→confirm_return画面
    @member = Member.find_by(id: params[:member_id])
    loan_ids = params[:loan_ids]|| []
    if loan_ids.empty?
      @error_message = "1つ以上チェックを入れてください。"
      @return_loans = @member.loans.where(return_date: nil)
      render :new, status: :unprocessable_entity
    else
      @loans_to_return = Loan.where(id: loan_ids)
      render :confirm_return
    end
  end

  def update
    loan_ids = params[:loan_ids] || []
    Loan.where(id: loan_ids).update_all(return_date: Time.current)
    flash[:success] = "資料を返却しました。"
    redirect_to new_counter_path(member_id: params[:member_id])
  end

  def confirm_loan
    @member = Member.find(params[:member_id])
    @return_loans = @member.loans.where(return_date: nil)
    @loan_date = params[:loan_date]
    stock_ids = params[:loan][:stock_ids].reject(&:blank?)

    @error_messages = []
    @errors = {}

    if stock_ids.empty? || @loan_date.nil?
      @error_messages << "1つ以上資料IDを入力してください。" if stock_ids.empty?
      @error_messages << "貸出年月日を入力してください。" if @loan_date.nil?
      @loans_to_confirm = []
      render :new, status: :unprocessable_entity
      return
    end
    
    stock_ids.each do |stock_id|
      stock = Stock.find_by(id: stock_id)
      if stock.nil?
        @errors[stock_id] = "存在しない資料IDです。"
      elsif stock.disposal_date.present?
        @errors[stock_id] = "この資料は廃棄済みです。"
      elsif Loan.where(stock_id: stock_id, return_date: nil).exists?
        @errors[stock_id] = "この資料は貸出中です。"
      end
    end
  
    if @errors.any? || @error_messages.any?
      render :new, status: :unprocessable_entity
    else
      @loans_to_confirm = stock_ids.map do |stock_id|
        loan = Loan.new(member: @member, stock_id: stock_id, loan_date: @loan_date)
        loan.set_due_date # 返却期日を設定
        loan
      end
      render :confirm_loan
    end
  end

  def create
    @member = Member.find(params[:member_id])
    @loan_date = params[:loan_date]
    stock_ids = params[:stock_ids].present? ? params[:stock_ids].split(',') : []
  
    @loans_to_confirm = stock_ids.map do |stock_id|
      loan = Loan.new(member: @member, stock_id: stock_id, loan_date: @loan_date)
      loan.set_due_date # 返却期日を設定
      loan
    end
    
    Loan.transaction do
      @loans_to_confirm.each(&:save!)
    end
    flash[:success] = "#{@loans_to_confirm.size}冊の貸出登録を行いました。"
    redirect_to new_counter_path(member_id: @member.id)
  end
end
