class ApplicationController < ActionController::Base
  before_action :set_breadcrumbs
  include SessionsHelper
  def require_logged_in
    unless logged_in?
      flash[:danger] = 'ログインしてください'
      redirect_to login_url
    end
  end
  def already_logged_in
    if logged_in?
      flash[:danger] = 'すでにログインしています'
      redirect_to root_path
    end
  end

  private

  def set_breadcrumbs
    # パンくずリストをセッションから取得
    session[:breadcrumbs] ||= []
    
    # ホームページなど特定のパスにアクセスしたときはパンくずリストをリセット
    if request.fullpath == root_path
      session[:breadcrumbs] = []
    else
      # すでにリストに含まれていない場合は追加
      unless session[:breadcrumbs].last == request.fullpath
        session[:breadcrumbs] << request.fullpath
      end
      
      # パンくずリストのサイズが5を超えた場合は古いものを削除
      session[:breadcrumbs].shift if session[:breadcrumbs].size > 5
    end
  end
end
