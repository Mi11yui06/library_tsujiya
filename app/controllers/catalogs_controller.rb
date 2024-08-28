class CatalogsController < ApplicationController
  before_action :require_logged_in
  
  def index
    @catalogs = Catalog.page(params[:page]).per(PER_PAGE)

    search_title = params[:search_title]
    search_isbn = params[:search_isbn]
    search_category = params[:search_category]
    search_author = params[:search_author]
    search_publisher = params[:search_publisher]

    @catalogs = @catalogs.where(isbn: search_isbn.to_i) if search_isbn.present?
    @catalogs = @catalogs.where('title LIKE ?', "%#{search_title}%") if search_title.present?
    @catalogs = @catalogs.where('author LIKE ?', "%#{search_author}%") if search_author.present?
    @catalogs = @catalogs.where('publisher LIKE ?', "%#{search_publisher}%") if search_publisher.present?
    @catalogs = @catalogs.where(category_id: search_category) if search_category.present?
    @catalogs = @catalogs.where('publish_date >= ?', 3.months.ago.to_date) if params[:recent_publication].to_i == 1  

    case params[:sort]
    when 'publish_date_asc'
      @catalogs = @catalogs.order(publish_date: :asc)
    when 'publish_date_desc'
      @catalogs = @catalogs.order(publish_date: :desc)
    else
      @catalogs = @catalogs.order(id: :desc)
    end
    
    @catalogs_count = @catalogs.total_count
  end

  def show
    @catalog = Catalog.find(params[:id])
    @stocks = Stock.where(catalog_id: @catalog.id)
  end

  def new
    @catalog = Catalog.new
    @categories = Category.all
  end

  def create
    @catalog = Catalog.new(catalog_params)
    if @catalog.save
      flash[:success] = '資料目録を登録しました'
      redirect_to @catalog
    else
      flash.now[:danger] = '登録できませんでした'
      @categories = Category.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @catalog = Catalog.find(params[:id])
    @categories = Category.all
  end

  def update
    @catalog = Catalog.find(params[:id])
    if @catalog.update(catalog_params)
      flash[:success] = '資料目録を更新しました'
      redirect_to catalog_path(@catalog)
    else
      flash.now[:danger] = '更新できませんでした'
      @categories = Category.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @catalog = Catalog.find(params[:id])
    @catalog.destroy
    flash[:success] = '削除しました'
    redirect_to catalogs_path
  end

  private
  def catalog_params
    params.require(:catalog).permit(:isbn, :category_id, :title, :author, :publisher, :publish_date)
  end
end
