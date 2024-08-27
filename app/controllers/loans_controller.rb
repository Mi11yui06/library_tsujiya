class LoansController < ApplicationController
  before_action :require_logged_in

  def index
    @loans = Loan.joins(stock: :catalog).order(id: :desc).page(params[:page]).per(PER_PAGE)
    
    search_member = params[:search_member]
    search_stock = params[:search_stock]
    serch_category = params[:search_category]
    year = params[:search_year]
    month = params[:search_month]
    day = params[:search_day]

    @member = Member.find_by(id: search_member)
    if @member
      @loan_available = @member.available_loans_count
    end

    @loans = @loans.where(member_id: search_member.to_i) if search_member.present?
    @loans = @loans.where(stock_id: search_stock.to_i) if search_stock.present?
    @loans = @loans.where("due_date < ? AND return_date IS NULL", Date.today) if params[:overdue].to_i == 1
    @loans = @loans.where(return_date: nil) if params[:on_loan].to_i == 1
    @loans = @loans.where('catalogs.category_id = ?', serch_category) if serch_category.present?
    @loans = @loans.where("EXTRACT(YEAR FROM loan_date) = ?", year.to_i) if year.present?
    @loans = @loans.where("EXTRACT(MONTH FROM loan_date) = ?", month.to_i) if month.present?
    @loans = @loans.where("EXTRACT(DAY FROM loan_date) = ?", day.to_i) if day.present?

    @loans_count = @loans.total_count
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
      @loan_available = @member.available_loans_count
    end
  end

  def confirm
    @loan = Loan.new(loan_params)
    @member = Member.find_by(id: @loan.member_id)
    @stock = Stock.find_by(id: @loan.stock_id)
    if @loan.valid?
      @loan.set_due_date
      render :confirm
    else
      render :new, status: :unprocessable_entity
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
    Rails.logger.debug("Received params: #{params.inspect}")
    if @loan.update(loan_params)
      flash[:success] = '更新しました'
      redirect_to loan_path(@loan)
    else
      flash.now[:danger] = '更新できませんでした'
      Rails.logger.debug(@loan.errors.full_messages) 
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
end