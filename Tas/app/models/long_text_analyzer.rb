class LongTextAnalyzer < SentiWordNet

  def get_score(string)
    # sentiment_total = super(string)
    # tokenize the string, also throw away some punctuation
    # tokens_avg = sentiment_total/super.tokenize(string)

    # tokenize the string, also throw away some punctuation
    tokens = tokenize(string)
    tokens.map! { |token|
      (@@sentihash[token + '#n'] ||
        @@sentihash[token + '#a'] ||
        @@sentihash[token + '#r'] ||
        @@sentihash[token + '#v'])
    }.select! { |f| (!f.nil? && f != 0) }
    if tokens.count > 0
      # Caso a frase não possua alguma palavra conhecida pelo SentiWordNet
      sentiment_total = tokens.reduce(:+)
      sentiment_avg = (sentiment_total / tokens.count).round(4)
    end
    sentiment_avg
  end
end