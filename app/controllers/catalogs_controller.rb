class CatalogsController < ApplicationController
  before_action :require_logged_in
  
  def index
    @catalogs = Catalog.order(:id).page(params[:page]).per(15)

    search_title = params[:search_title]
    search_isbn = params[:search_isbn]
    search_category = params[:search_category]

    @catalogs = @catalogs.where(isbn: search_isbn.to_i) if search_isbn.present?
    @catalogs = @catalogs.where('title LIKE ?', "%#{search_title}%") if search_title.present?
    @catalogs = @catalogs.where(category_id: search_category) if search_category.present?
    @catalogs = @catalogs.where('publish_date >= ?', 3.months.ago.to_date) if params[:recent_publication].to_i == 1

  end

  def show
    @catalog = Catalog.find(params[:id])
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
    redirect_to catalogs_path
  end

  private
  def catalog_params
    params.require(:catalog).permit(:isbn, :category_id, :title, :author, :publisher, :publish_date)
  end
end
