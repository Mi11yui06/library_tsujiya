class MembersController < ApplicationController
  before_action :require_logged_in
  
  def index
    @members = Member.order(:id).page(params[:page]).per(PER_PAGE)

    # 検索パラメータを取得
    search_id = params[:search_id]
    search_name = params[:search_name]

    # 検索条件を適用
    @members = @members.where(id: search_id.to_i) if search_id.present?
    @members = @members.where('name LIKE ?', "%#{search_name}%") if search_name.present?
    @members = @members.where.not(remove_date: nil) if params[:removed_member].to_i == 1

    @members_count = @members.total_count
  end

  def show
    @member = Member.find(params[:id])
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(member_params)
    if @member.save
      flash[:success] = '登録しました'
      redirect_to @member
    else
      flash.now[:danger] = '登録できませんでした'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])
    if @member.update(member_params)
      flash[:success] = '更新しました'
      redirect_to member_path(@member)
    else
      flash.now[:danger] = '更新できませんでした'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    flash[:success] = '削除しました'
    redirect_to members_path
  end

  private
  def member_params
    params.require(:member).permit(:name, :post_code, :address, :tel, :email, :birth_date, :join_date, :remove_date)
  end
end