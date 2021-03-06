class Admin::OfficersController < ApplicationController
  before_action :set_officer, only: [:edit, :update]
  authorize_resource

  def index
    @officers = Officer.ordered.include_players
  end

  def show
    @officer = Officer.include_players.find(params[:id])
    if @officer.player.present?
      @users = @officer.player.users.reject { |u| u.roles.nil? }
    end
    officers = Officer.ordered
    index = officers.index { |o| o.id == @officer.id }
    if index
      @next = officers[index + 1]
      @prev = officers[index - 1] if index > 0
    end
    @entries = @officer.journal_search if can?(:update, Officer)
  end

  def update
    if @officer.update(officer_params)
      @officer.journal(:update, current_user, request.remote_ip)
      redirect_to [:admin, @officer], notice: "Officer was successfully updated"
    else
      flash_first_error(@officer, base_only: true)
      render action: "edit"
    end
  end

  private

  def set_officer
    @officer = Officer.find(params[:id])
  end

  def officer_params
    params[:officer].permit(:player_id, :rank, :active, :executive)
  end
end
