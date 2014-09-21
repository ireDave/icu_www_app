class GamesController < ApplicationController
  def index
    if params[:format] == "pgn"
      send_pgn_games(Game.search_unpaged(params, games_path)) and return
    end

    @games = Game.search(params, games_path)
    flash.now[:warning] = t("no_matches") if @games.count == 0
    save_last_search(@games, :games)
  end

  def show
    @game = Game.find(params[:id])
    @prev_next = Util::PrevNext.new(session, Game, params[:id])
    @entries = @game.journal_entries if can?(:update, Game)
    respond_to do |format|
      format.html
      format.pgn { send_pgn_file(@game.to_pgn) }
    end
  end

  private

  def send_pgn_games(games)
    pgn_content = ""
    games.find_each {|game| pgn_content += "#{game.to_pgn}\n\n" }
    send_pgn_file pgn_content
  end

  def send_pgn_file(pgn_content)
    send_data pgn_content, filename: "icu.pgn", type: :pgn
  end
end
