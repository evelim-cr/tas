class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]
  #before_action :get_tags, only: [:reddit_search]

  # GET /queries
  # GET /queries.json
  def index
    @queries = Query.all
    @sources = Source.all
  end

  # GET /queries/1
  # GET /queries/1.json
  def show
  end

  # GET /queries/new
  def new
    @query = Query.new
  end

  def create_tag(tag)
    if !(tag.empty?)
      @tags << Tag.getTag(tag)
    end   
  end


  # GET /queries/1/edit
  def edit
  end

  # POST /queries
  # POST /queries.json
  def create
    @query = Query.new(query_params)

    respond_to do |format|
      if @query.save
        format.html { redirect_to @query, notice: 'Query was successfully created.' }
        format.json { render :show, status: :created, location: @query }
      else
        format.html { render :new }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /queries/1
  # PATCH/PUT /queries/1.json
  def update
    respond_to do |format|
      if @query.update(query_params)
        format.html { redirect_to @query, notice: 'Query was successfully updated.' }
        format.json { render :show, status: :ok, location: @query }
      else
        format.html { render :edit }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /queries/1
  # DELETE /queries/1.json
  def destroy
    @query.destroy
    respond_to do |format|
      format.html { redirect_to queries_url, notice: 'Query was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /queries/search
  def search
    if params[:keyword].nil? || params[:keyword].empty?
      redirect_to root_path, notice: "Keyword can't be blank!"
    else
      @k1 = Keyword.getKeyword(params[:keyword])
      @tags = []
      create_tag(params[:tag1])
      create_tag(params[:tag2])
      create_tag(params[:tag3])

      @query = Query.getQuery(@k1,@tags)
      reddit_search(@query)
      # youtube_search(@query)
      # twitter_search(@query)

      @sentiments = posts_analyze(@query.posts)
    end
  end

  def reddit_search(query = Query.first, limit = 100)
    # query = Query.find(query)
    # Cria um usuário anônimo no Reddit
    client = RedditKit::Client.new
    # Cria a string a ser procurada no Reddit
    query_string = "selftext:" + query.keyword.name
    if query.tags.count > 0 
       query_string << " AND (selftext:" << query.tags.pluck(:name).join(" OR selftext:") << " nsfw:no)"
    end
    # Realiza a busca
    results = client.search(query_string, {:limit => limit})
    # O nome da fonte de extração deve coincidir com o configurado em db/seeds.rb
    src = Source.where(:name => "Reddit").first
    results.each do |r|
      # Procura no banco de dados local por um post com o mesmo ID do que foi extraído
      already_created = Post.where(:origin_id => r.id).first
      # Se encontrar
      if already_created.present?
        # Se o mesmo post foi alterado, atualiza seu texto e data
        if r.text != already_created.text
          already_created.text = r.text
        end
        # Apenas indica que este post foi encontrado pela query passada
        if !already_created.queries.exists?(query)
          already_created.queries << query
          already_created.save
        end
      else
        # Se não, cria um novo post e também associa à esta query
        post = Post.new()
        post.text = r.selftext
        post.author = r.author
        post.frequency = r.score
        post.postDate = r.created_at
        post.origin_id = r.id
        post.source = src
        post.queries << query
        post.save
      end
    end
  end

  def posts_analyze(posts)
    # Carregando os valores padrão da base SentiWordNet
    SentiWordNet.load_defaults
    # Instanciando um analizador do SentiWordNet
    analyzer = SentiWordNet.new

    posts_sentiments = Hash.new
    posts.each do |post|
      posts_sentiments[post.id] = analyzer.get_score(post.text).round(4)
    end
    return posts_sentiments
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query
      @query = Query.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def query_params
      params[:query]
    end
end
