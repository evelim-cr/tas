# encoding: UTF-8
class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]
  #before_action :get_tags, only: [:reddit_search]

  @@regex_emoji = /[\u{203C}\u{2049}\u{20E3}\u{2122}\u{2139}\u{2194}-\u{2199}\u{21A9}-\u{21AA}\u{231A}-\u{231B}\u{23E9}-\u{23EC}\u{23F0}\u{23F3}\u{24C2}\u{25AA}-\u{25AB}\u{25B6}\u{25C0}\u{25FB}-\u{25FE}\u{2600}-\u{2601}\u{260E}\u{2611}\u{2614}-\u{2615}\u{261D}\u{263A}\u{2648}-\u{2653}\u{2660}\u{2663}\u{2665}-\u{2666}\u{2668}\u{267B}\u{267F}\u{2693}\u{26A0}-\u{26A1}\u{26AA}-\u{26AB}\u{26BD}-\u{26BE}\u{26C4}-\u{26C5}\u{26CE}\u{26D4}\u{26EA}\u{26F2}-\u{26F3}\u{26F5}\u{26FA}\u{26FD}\u{2702}\u{2705}\u{2708}-\u{270C}\u{270F}\u{2712}\u{2714}\u{2716}\u{2728}\u{2733}-\u{2734}\u{2744}\u{2747}\u{274C}\u{274E}\u{2753}-\u{2755}\u{2757}\u{2764}\u{2795}-\u{2797}\u{27A1}\u{27B0}\u{2934}-\u{2935}\u{2B05}-\u{2B07}\u{2B1B}-\u{2B1C}\u{2B50}\u{2B55}\u{3030}\u{303D}\u{3297}\u{3299}\u{1F004}\u{1F0CF}\u{1F170}-\u{1F171}\u{1F17E}-\u{1F17F}\u{1F18E}\u{1F191}-\u{1F19A}\u{1F1E7}-\u{1F1EC}\u{1F1EE}-\u{1F1F0}\u{1F1F3}\u{1F1F5}\u{1F1F7}-\u{1F1FA}\u{1F201}-\u{1F202}\u{1F21A}\u{1F22F}\u{1F232}-\u{1F23A}\u{1F250}-\u{1F251}\u{1F300}-\u{1F320}\u{1F330}-\u{1F335}\u{1F337}-\u{1F37C}\u{1F380}-\u{1F393}\u{1F3A0}-\u{1F3C4}\u{1F3C6}-\u{1F3CA}\u{1F3E0}-\u{1F3F0}\u{1F400}-\u{1F43E}\u{1F440}\u{1F442}-\u{1F4F7}\u{1F4F9}-\u{1F4FC}\u{1F500}-\u{1F507}\u{1F509}-\u{1F53D}\u{1F550}-\u{1F567}\u{1F5FB}-\u{1F640}\u{1F645}-\u{1F64F}\u{1F680}-\u{1F68A}]/

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

  def twitter_search(query = Query.first, limit = 2)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = "eSSsknWpxWla5j95AhE4Ui3yj"
      config.consumer_secret = "UICqhsGSLkTKV6hgnrVteWocqqknttEmJk5ZbVhMAxRIi4duu5"
    end

    query.tags.count>0 ? searchTerm="#{query.keyword.name} #{query.tags.first.name}" : searchTerm=query.keyword.name
    if query.tags.count>1
      query.tags.each { |t|
        searchTerm=searchTerm+" OR #{t.name}"
      }
    end

    src = Source.where(:name => "Twitter").first
    results = client.search("#{searchTerm} -rt", lang: "en", count: limit)
    # máximo de 100 tweets por query
    results.to_h[:statuses].each { |t|
      already_created = Post.where(:origin_id => t[:id]).first
      if already_created.present?
        # Apenas indica que este post foi encontrado pela query passada
        if !already_created.queries.exists?(query)
          already_created.queries << query
          already_created.save
        end
      else
        # Se não, cria um novo post e também associa à esta query
        post = Post.new()
        post.text = t[:text]
        post.author = t[:user][:screen_name]
        post.frequency = t[:retweet_count]+1
        post.postDate = t[:created_at]
        post.origin_id = t[:id]
        post.source = src
        post.queries << query
        post.save
      end
    }
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
      twitter_search(@query)

      @sentiments = posts_analyze(@query.posts)
      total = @sentiments.count

      resume = {}
      labels = ['Very positive', 'positive', 'rather positive', 'rather negatives', 'negatives', 'Very negative']
      resume[labels[0]] = (@sentiments.values.select{ |d| d >= 0.5}.count.to_f/total*100).round(2)
      resume[labels[1]] = (@sentiments.values.select{ |d| d >= 0.25 && d < 0.5}.count.to_f/total*100).round(2)
      resume[labels[2]] = (@sentiments.values.select{ |d| d >= 0 && d < 0.25}.count.to_f/total*100).round(2)
      resume[labels[3]] = (@sentiments.values.select{ |d| d >= -0.25 && d < 0}.count.to_f/total*100).round(2)
      resume[labels[4]] = (@sentiments.values.select{ |d| d >= -0.5 && d < -0.25}.count.to_f/total*100).round(2)
      resume[labels[5]] = (@sentiments.values.select{ |d| d < -0.5}.count.to_f/total*100).round(2)
      @chart = LazyHighCharts::HighChart.new('pie') do |f|
        f.chart({:defaultSeriesType=>"pie" , :margin=> [50, 200, 60, 170], } )
        f.series(:type=> 'pie', 
                :data=> [
                  {:name => labels[0], :y => resume[labels[0]], :color => "#1abc9c"},
                  {:name => labels[1], :y => resume[labels[1]], :color => "#2ecc71"},
                  {:name => labels[2], :y => resume[labels[2]], :color => "#bdc3c7"},
                  {:name => labels[3], :y => resume[labels[3]], :color => "#7f8c8d"},
                  {:name => labels[4], :y => resume[labels[4]], :color => "#e74c3c"},
                  {:name => labels[5], :y => resume[labels[5]], :color => "#c0392b"}
                ],
                :center=> [100, 80], :size=> 100, :showInLegend=> false)
        f.options[:title][:text] = "Scores distribution"
        f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'}) 
        f.plot_options(:pie=>{
          :allowPointSelect=>true, 
          :cursor=>"pointer" , 
          :dataLabels=>{
            :enabled=>true,
            :color=>"black",
            :format=>'<b>{point.name}</b>',
            :style=>{
              :font=>"13px Trebuchet MS, Verdana, sans-serif"
            }
          }
        })
        f.tooltip(:pointFormat=> '<b>{point.percentage:.1f}%</b>')                
      end
    end
  end

  def posts_analyze(posts)
    # Carregando os valores padrão da base SentiWordNet
    LongTextAnalyzer.load_defaults
    # Instanciando um analizador do SentiWordNet
    analyzer = LongTextAnalyzer.new

    posts_sentiments = Hash.new
    posts.each do |post|
      if analyzer.get_score(post.text)
        posts_sentiments[post.id] = analyzer.get_score(post.text)
      else
        Post.delete(post.id)
      end
    end
    return posts_sentiments
  end

  def twitter_search(query, limit = 10)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = "eSSsknWpxWla5j95AhE4Ui3yj"
      config.consumer_secret = "UICqhsGSLkTKV6hgnrVteWocqqknttEmJk5ZbVhMAxRIi4duu5"
    end

    query.tags.count > 0 ? searchTerm="#{query.keyword.name} #{query.tags.first.name}" : searchTerm = query.keyword.name
    if query.tags.count>1
      query.tags.each { |t|
        searchTerm=searchTerm+" OR #{t.name}"
      }
    end

    src = Source.where(:name => "Twitter").first
    results = client.search("#{searchTerm} -rt", lang: "en", count: limit)
    # máximo de 100 tweets por query
    results.to_h[:statuses].each { |t|
      already_created = Post.where(:origin_id => t[:id]).first
      if already_created.present?
        # Apenas indica que este post foi encontrado pela query passada
        if !already_created.queries.exists?(query)
          already_created.queries << query
          already_created.save
        end
      else
        clean_text = t[:text].gsub @@regex_emoji, ''
        # Se não, cria um novo post caso seu texto retirando caracteres inválidos para o banco e também associa à esta query
        if clean_text.length > 0
          post = Post.new()
          post.text = clean_text
          post.author = t[:user][:screen_name]
          post.frequency = t[:retweet_count]+1
          post.post_date = t[:created_at]
          post.origin_id = t[:id]
          post.source = src
          post.queries << query
          post.save
        end
      end
    }
  end

  def reddit_search(query, limit = 10)
    # query = Query.find(query)
    # Cria um usuário anônimo no Reddit
    client = RedditKit::Client.new
    # Cria a string a ser procurada no Reddit
    query_string = "selftext:" + query.keyword.name
    if query.tags.count > 0 
       query_string << " AND (selftext:" << query.tags.pluck(:name).join(" OR selftext:") << " nsfw:no sort:new)"
    end
    # Realiza a busca
    results = client.search(query_string, {:limit => limit})
    # O nome da fonte de extração deve coincidir com o configurado em db/seeds.rb
    src = Source.where(:name => "Reddit").first
    results.each do |r|
      # Procura no banco de dados local por um post com o mesmo ID do que foi extraído
      already_created = Post.where(:origin_id => r.id).first
      # Se encontrar a publicação remota no banco local
      if already_created.present?
        # Se o mesmo post foi alterado, atualiza seu texto e data
        if r.text != already_created.text
          already_created.text = r.selftext
        end
        # Apenas indica que este post foi encontrado pela query passada
        if !already_created.queries.exists?(query)
          already_created.queries << query
          already_created.save
        end
      else
        # Se não, cria um novo post e também associa à esta query
        clean_text = r.selftext.gsub @@regex_emoji, ''
        # Se não, cria um novo post caso seu texto retirando caracteres inválidos para o banco e também associa à esta query
        if clean_text.length > 0
          post = Post.new()
          post.text = clean_text
          post.author = r.author
          post.frequency = r.score
          post.post_date = r.created_at
          post.origin_id = r.id
          post.source = src
          post.queries << query
          post.save
        end
      end
    end
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
