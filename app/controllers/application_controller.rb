class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper


  # ---------下記既存アプリの記述-------------------
  $days_of_the_week = %w{日 月 火 水 木 金 土}

  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
 def set_one_month 
  @first_day = params[:date].nil? ?
  Date.current.beginning_of_month : params[:date].to_date
  @last_day = @first_day.end_of_month
  one_month = [*@first_day..@last_day]

  @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

  unless one_month.count == @attendances.count
    ActiveRecord::Base.transaction do
      one_month.each { |day| @user.attendances.create!(worked_on: day) }
    end
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
  end

  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
  # ---------------------------------------------

  # ログイン後に遷移するpathを設定
  def after_sign_in_path_for(resource)
    case resource
    when SystemAdmin
      system_admins_path
    when Teacher
      if current_teacher.admin == true && resource.sign_in_count == 1
        edit_using_class_classrooms_path(school_url: params[:school_url])
      else
        show_teachers_path(school_url: params[:school_url])
      end
      # teachers_path(id: current_teacher.id)
    end
  end

  # ログアウト後に遷移するpathを設定
  # def after_sign_out_path_for(resource)
  #   debugger
  #   case resource
  #   when SystemAdmin
  #     root_path
  #   when Teacher
  #     top_path(school_url: params[:school_url])
  #   end
  # end

   # school_urlの設定
  def set_school_url
    @school = School.find_by(school_url: params[:id])
  end

   # school間のアクセス制限
  # def check_school_url
  #   return if system_admin_signed_in?

  #   routing_error if params[:school_url] != School.find(id: current_teacher.school_id).school_url
  # end

  # 管理者かどうかの判定
  def admin_teacher
    redirect_to top_path(school_url: params[:school_url]) unless current_teacher.admin?
  end
end  
