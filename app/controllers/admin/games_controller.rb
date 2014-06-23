class Admin::GamesController < ApplicationController
  before_action :set_game, only: [:edit, :update, :destroy]
  authorize_resource

  def update
    normalize_newlines(:game, :moves)
    if @game.update(game_params)
      @game.journal(:update, current_user, request.ip)
      redirect_to @game, notice: "Game was successfully updated"
    else
      flash.now.alert = @game.errors[:base].first if @game.errors[:base].any?
      render action: "edit"
    end
  end

  def destroy
    @game.journal(:destroy, current_user, request.ip)
    @game.destroy
    redirect_to games_path, notice: "Game was successfully deleted"
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params[:game].permit(:annotator, :black, :black_elo, :date, :eco, :event, :fen, :moves, :ply, :result, :round, :site, :white, :white_elo)
  end
end
