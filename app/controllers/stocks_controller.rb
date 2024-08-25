class StocksController < ApplicationController
  before_action :require_logged_in
  
  def index
    @stocks = Stock.joins(:catalog).order(id: :desc).page(params[:page]).per(15)

    search_id = params[:search_id]
    search_isbn = params[:search_isbn]
    search_title = params[:search_title]

    @stocks = @stocks.where(catalog_id: params[:catalog_id]) if params[:catalog_id].present?
    @stocks = @stocks.where(id: search_id.to_i) if search_id.present?
    @stocks = @stocks.where('catalogs.isbn = ?', search_isbn) if search_isbn.present?
    @stocks = @stocks.where('catalogs.title LIKE ?', "%#{search_title}%") if search_title.present?
  end

  def show
    @stock = Stock.find(params[:id])
  end

  def new
    @stock = Stock.new
    if params[:catalog_id].present?
      @catalog = Catalog.find(params[:catalog_id])
    end
  end

  def create
    number_of_copies = params[:stock][:number_of_copies].to_i
    @stock = Stock.new(stock_params)
    @catalog = Catalog.find(params[:stock][:catalog_id]) if params[:stock][:catalog_id].present?

    if number_of_copies == 0
      @stock.errors.add(:base, "冊数を入力してください")
      render :new, status: :unprocessable_entity and return
    end
    
    number_of_copies.times do
      @stock = Stock.new(stock_params)
      unless @stock.save
        flash.now[:danger] = '登録できませんでした'
        @catalog = Catalog.find(params[:stock][:catalog_id])
        render :new, status: :unprocessable_entity
        return
      end
    end
      flash[:success] = "#{number_of_copies}冊の在庫を登録しました"
      redirect_to stocks_path
  end

  def edit
    @stock = Stock.find(params[:id])
  end

  def update
    @stock = Stock.find(params[:id])
    if @stock.update(stock_params)
      flash[:success] = '資料目録を更新しました'
      redirect_to stock_path(@stock)
    else
      flash.now[:danger] = '更新できませんでした'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stock = Stock.find(params[:id])
    @stock.destroy
    flash[:success] = '削除しました'
    redirect_to stocks_path
  end

  private
  def stock_params
    params.require(:stock).permit(:arrival_date, :disposal_date, :remarks, :catalog_id)
  end
end
