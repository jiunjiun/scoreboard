class BoardsController < ApplicationController

  before_action :set_board, only: [:show, :players, :edit, :update, :destroy]

  def new
    @board = Board.new
  end

  def show
    @bps       = BoardPlayer.where(board: @board)
    @records   = Record.includes(:board, :board_player).order(created_at: :desc)
    @score_sum = Record.where(board: @board).group(:board_player_id).sum(:score)
    @new_game  = Record.new
  end

  def edit
  end

  def create
    @board = Board.new(board_params)
    if @board.save_of_user(current_player)
      redirect_to root_path
    else
      render :new
    end
  end

  def update
    if @board.update(board_params)
      redirect_to root_path
    else
      render :edit
    end
  end

  def destroy
    @board.destroy
    redirect_to root_path
  end

  # Game
  def create_game
    if params[:scores].size == params[:board_players].size
      scores = params[:scores]
      scores.each_with_index do |score, i|
        record = Record.new({board_id: params[:id], board_player_id: params[:board_players][i], score: score})
        t = record.save
        Rails.logger.debug { "+++++ #{record.to_json}" }
      end
    end
    redirect_to board_path
  end

  def update_game

    redirect_to board_path
  end
  # --

  # Player
  def players
    @new_bp = BoardPlayer.new
    @bps    = BoardPlayer.where({board: @board})
  end

  def search_player
    @players = Player.where('name like ?', "#{params[:name]}%")
  end

  def create_player
    bp = BoardPlayer.new(board_player_params)
    redirect_to players_board_path if bp.save_of_board(params[:id])
  end

  def destroy_player
    BoardPlayer.find(params[:bp_id]).delete
    redirect_to players_board_path
  end
  # --

  private
    def set_board
      @board = Board.find(params[:id])
    end

    def board_params
      params.require(:board).permit(:master, :title, :wager)
    end

    def board_player_params
      params.require(:board_player).permit(:board_id, :player_id, :anonymous)
    end
end
