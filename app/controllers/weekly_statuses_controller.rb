# encoding: UTF-8
# Copyright 2014 innoQ Deutschland GmbH

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
class WeeklyStatusesController < ApplicationController
  def index
    @statuses = WeeklyStatus.recent.page(params[:page])

    respond_to do |format|
      format.html
      format.atom
    end
  end

  def by_author
    @statuses = WeeklyStatus.where(:author => params[:author]).recent

    respond_to do |format|
      format.html do
        @statuses = @statuses.page(params[:page])
        render :index
      end
      format.atom { render :index }
    end
  end

  def by_week
    @statuses = WeeklyStatus.by_week(params[:week]).recent
    if params[:week].to_i > 1 && WeeklyStatus.statuses_in_previous_week(params[:week]).count > 0
      @previous_week_statuses = params[:week].to_i - 1
    end
    count_cw = Date.today.end_of_year.beginning_of_week.strftime("%W").to_i
    if params[:week].to_i < count_cw && WeeklyStatus.statuses_in_next_week(params[:week]).count > 0
      @next_week_statuses = params[:week].to_i + 1
    end

    respond_to do |format|
      format.html
    end
  end

  def show
    @status = WeeklyStatus.find(params[:id])
    @edit_comment = @status.comments.new
    @comments = @status.comments
  end

  def new
    @status = WeeklyStatus.new do |s|
      s.author = @user
    end

    render :edit
  end

  def create
    @status = WeeklyStatus.new(params[:weekly_status])
    @status.author = @user
    if params[:commit] == "Vorschau"
      @status.regenerate_html
      @preview = true
      render :edit
    elsif @status.save
      flash[:success] = "Der Eintrag wurde gespeichert."
      redirect_to weekly_statuses_path
    else
      flash[:error] = "Der Eintrag konnte nicht gespeichert werden."
      render :edit
    end
  end

  def edit
    @status = WeeklyStatus.find(params[:id])
  end

  def update
    @status = WeeklyStatus.find(params[:id])
    if params[:commit] == "Vorschau"
      @status.assign_attributes(params[:weekly_status])
      @status.regenerate_html
      @preview = true
      render :edit
    elsif @status.update_attributes(params[:weekly_status])
      flash[:success] = "Der Eintrag wurde geändert."
      redirect_to weekly_statuses_path
    else
      flash[:error] = "Der Eintrag konnte nicht geändert werden."
      render :edit
    end
  end

  def destroy
    @status = WeeklyStatus.find(params[:id])
    if @status.owned_by?(@user) && @status.destroy
      flash[:success] = "Der Eintrag wurde gelöscht."
    else
      flash[:error] = "Der Eintrag konnte nicht gelöscht werden."
    end

    redirect_to weekly_statuses_path
  end
end
