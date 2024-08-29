module ApplicationHelper
  
  BREADCRUMBS = {
    'members#index' => [['会員台帳', :members_path]],
    'members#new' =>  [['会員台帳', :members_path], ['新規会員登録', :new_member_path]],
    'members#edit' => [['会員台帳', :members_path], ['会員詳細', :new_member_path], ['会員情報編集', :new_member_path]],
    'members#show' => [['会員台帳', :members_path], ['会員詳細', :member_path]],
    'catalogs#index' => [['資料目録', :catalogs_path]],
    'catalogs#show' => [['資料目録', :catalogs_path], ['目録詳細', :catalog_path]],
    'catalogs#new' => [['資料目録', :catalogs_path], ['新規目録登録', :new_catalog_path]],
    'catalogs#edit' => [['資料目録', :catalogs_path], ['目録詳細', :catalog_path], ['目録情報編集', :edit_catalog_path]],
    'stocks#index' => [['在庫台帳', :stocks_path]],
    'stocks#show' => [['在庫台帳', :stocks_path], ['在庫詳細', :stock_path]],
    'stocks#new' => [['在庫台帳', :stocks_path], ['新規在庫登録', :new_stock_path]],
    'stocks#edit' => [['在庫台帳', :stocks_path], ['在庫詳細', :stock_path], ['在庫情報編集', :edit_stock_path]],
    'loans#index' => [['貸出台帳', :loans_path]],
    'loans#show' => [['貸出台帳', :loans_path], ['貸出詳細', :loan_path]],
    'loans#new' => [['貸出台帳', :loans_path], ['新規貸出登録', :new_loan_path]],
    'loans#edit' => [['貸出台帳', :loans_path], ['貸出詳細', :loan_path], ['貸出情報編集', :edit_loan_path]],
    'loans#confirm' => [['貸出台帳', :loans_path], ['新規貸出登録', :new_loan_path],  ['貸出編集確認', :confirm_loans_path]],
    'counters#new' =>  [['貸出 / 返却', :new_counter_path]],
    'counters#confirm_return' =>  [['貸出 / 返却', :new_counter_path], ['返却確認', :confirm_return_counters_path]],
    'counters#confirm_loan' =>  [['貸出 / 返却', :new_counter_path], ['貸出確認', :confirm_loan_counters_path]]
  }.freeze
  
  def breadcrumb_trail
    breadcrumbs = []

    # ホーム画面ではアイコンなし
    if current_page?(root_path)
      breadcrumbs << {}
    else
      # ホームへのリンク（家のアイコン）
      breadcrumbs << { title: content_tag(:i, "", class: "bi bi-house-fill") + " ホーム", url: root_path }
    end

    # 現在のコントローラーとアクションに対応するパンくずリストの配列を取得
    controller_action = "#{controller_name}##{action_name}"
    if BREADCRUMBS[controller_action]
      BREADCRUMBS[controller_action].each do |crumb, path_method|
        breadcrumbs << { title: crumb, url: send(path_method, params[:id]) }
      end
    end

    breadcrumbs
  end

  # パンくずリストを生成するためのヘルパー
  def generate_breadcrumb_links
    breadcrumb_trail.each_with_index.map do |breadcrumb, index|
      if index == breadcrumb_trail.size - 1
        breadcrumb[:title] # 最後の項目はリンクなし
      else
        link_to(breadcrumb[:title].html_safe, breadcrumb[:url]) + content_tag(:span, '>', class: 'breadcrumb-separator')
      end
    end.join.html_safe
  end
end
