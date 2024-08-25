class LoansController < ApplicationController
  before_action :require_logged_in

  def index
    @loans = Loan.order(id: :desc).page(params[:page]).per(15)
    
    search_member = params[:search_member]
    search_stock = params[:search_stock]

    @member = Member.find_by(id: search_member)
    if @member
      overdue_loans = @member.loans.where("return_date IS NULL AND due_date < ?", Date.today)
      if overdue_loans.exists?
        @loan_available = 0
      else
        on_loan = @member.loans.where("return_date IS NULL AND loan_date IS NOT NULL")
        @loan_available = [5 - on_loan.count, 0].max
      end
    end

    @loans = @loans.where(member_id: search_member.to_i) if search_member.present?
    @loans = @loans.where(stock_id: search_stock.to_i) if search_stock.present?
    @loans = @loans.where("due_date <= ? AND return_date IS NULL", 1.days.ago) if params[:overdue].to_i == 1
  end

  def show
    @loan = Loan.find(params[:id])
  end

  def new
    @loan = Loan.new(
      member_id: params[:member_id],
      stock_id: params[:stock_id],
      loan_date: params[:loan_date],
      due_date: params[:due_date]
    )
    @member = Member.find_by(id: params[:member_id])
    if @member
      overdue_loans = @member.loans.where("return_date IS NULL AND due_date < ?", Date.today)
      if overdue_loans.exists?
        @loan_available = 0
      else
        on_loan = @member.loans.where("return_date IS NULL AND loan_date IS NOT NULL")
        @loan_available = [5 - on_loan.count, 0].max
      end
    end
  end

  def confirm
    @loan = Loan.new(loan_params)
    @member = Member.find_by(id: @loan.member_id)

    if @member
      overdue_loans = @member.loans.where("return_date IS NULL AND due_date < ?", Date.today)
      if overdue_loans.exists?
        @loan_available = 0
      else
        on_loan = @member.loans.where("return_date IS NULL AND loan_date IS NOT NULL")
        @loan_available = [5 - on_loan.count, 0].max
      end
    end

    @stocks = []
    @due_dates = []
    @stock_errors = []

    stock_ids = params[:loan][:stock_ids].reject(&:blank?)
    if stock_ids.empty?
      @loan.errors.add(:base, "少なくとも1冊の資料IDが必要です")
      render :new, status: :unprocessable_entity
      return
    end

    stock_ids.each_with_index do |stock_id, i|
      stock = Stock.find_by(id: stock_id)
      if stock.nil?
        @stock_errors[i]<< "資料ID: #{stock_id} は存在しません"
      elsif stock.disposal_date.present?
        @stock_errors[i] << "資料ID: #{stock_id} は廃棄されています"
      elsif Loan.exists?(stock_id: stock.id, return_date: nil)
        @stock_errors[i] << "資料ID: #{stock_id} は貸出中です"
      else
        @stocks << stock
        @due_dates << @loan.set_due_date 
      end
    end

    if @stock_errors.any? { |error| error.present? } || @loan.loan_date.blank?
      @loan.errors.add(:base, "貸出年月日を入力してください") if @loan.loan_date.blank?
      render :new, status: :unprocessable_entity
    else
      render :confirm
    end
  end

  def create
    @loan = Loan.new(loan_params)

    if @loan.save
      flash[:success] = '新規貸出を登録しました'
      redirect_to @loan
    else
      flash.now[:danger] = '登録できませんでした'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  @loan = Loan.find(params[:id])
  end

  def update
    @loan = Loan.find(params[:id])
    if @loan.update(loan_params)
      flash[:success] = '返却記録を登録しました'
      redirect_to loan_path(@loan)
    else
      flash.now[:danger] = '登録できませんでした'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @loan = Loan.find(params[:id])
    @loan.destroy
    redirect_to loans_path
  end

  private
  
  def loan_params
    params.require(:loan).permit(:member_id, :stock_id, :loan_date, :due_date, :return_date, :remarks)
  end

  def member_overdue?(member)
    overdue_loans = Loan.where(member_id: member.id, return_date: nil).where("due_date < ?", Date.today)
    overdue_loans.any?
  end
end
