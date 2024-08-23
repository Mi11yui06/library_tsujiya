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
  end

  def confirm
    @loan = Loan.new(loan_params)
    @member = Member.find_by(id: @loan.member_id)
    @stock = Stock.find_by(id: @loan.stock_id)
    
    # 会員IDの検証
    if @loan.member_id.blank?
      @loan.errors.add(:base, "会員IDを入力してください")
    elsif @member.nil?
      @loan.errors.add(:base, "指定された会員IDは存在しません")
    elsif @member.remove_date.present?
      @loan.errors.add(:base, "指定された会員は退会しています")
    elsif member_overdue?(@member)
      @loan.errors.add(:base, "指定された会員は延滞中です")
    end

    # 資料IDの検証
    if @loan.stock_id.blank?
      @loan.errors.add(:base, "資料IDを入力してください")
    elsif @stock.nil?
      @loan.errors.add(:base, "指定された資料IDは存在しません")
    elsif @stock.disposal_date.present?
      @loan.errors.add(:base, "指定された資料は廃棄されています")
    elsif Loan.exists?(stock_id: @loan.stock_id, return_date: nil)
      @loan.errors.add(:base, "指定された資料は貸出中です")
    end

    if @loan.errors.any?
      render :new, status: :unprocessable_entity
    else
      @loan.set_due_date if @loan.loan_date.present?
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
