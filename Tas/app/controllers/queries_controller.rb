class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]
  #before_action :get_tags, only: [:reddit_search]

  # GET /queries
  # GET /queries.json
  def index
    @queries = Query.all
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

  def search
    if params[:keyword].nil? || params[:keyword].empty?
      redirect_to root_path, notice: "Keyword can't be blank!"
    else
      @k1 = Keyword.getKeyword(params[:keyword])
      @tags = []
      create_tag(params[:tag1])
      create_tag(params[:tag2])
      create_tag(params[:tag3])
      # render :text => "Informed keyword was: " + @k1      
      # @tags << Tag.find(1) << Tag.find(2) << Tag.find(3)
      @query = Query.getQuery(@k1,@tags)
      @boatarde = reddit_search(@query)
      redirect_to queries_results_path
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

  def reddit_search(query = Query.first, limit = 2)
    # Create an anonymous reddit user
    client = RedditKit::Client.new
    # Create the query string to be used in search
    query = Query.find(query)
    query_string = query.keyword.name + " AND (" + query.tags.pluck(:name).join(" OR ") + ")"
    results = client.search(query_string, {:limit => limit})
    # Source name must match source name created on db/seeds.rb
    src = Source.where(:name => "reddit".capitalize).first
    posts = []
    results.each do |r|
      # Search local database to check if a post with the same ID was already extracted
      already_created = Post.where(:origin_id => r.id)
      # If this is a new post, create it
      if already_created.empty?
        post = Post.new()
        post.text = r.selftext
        post.author = r.author
        post.frequency = r.score
        post.postDate = r.created_at
        post.origin_id = r.id
        post.source = src
        post.query = query
        post.save
      else
        # Else fetch the post from database
        post = already_created
      end
      posts << post
    end
    return posts
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
