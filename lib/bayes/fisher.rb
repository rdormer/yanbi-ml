module Yanbi

  class Fisher < Yanbi::Bayes
  
    def classify(text)
      max_score(text) do |cat, doc|
        fisher_score(cat, doc)
      end
    end
  
    private
  
    def fisher_score(category, document)
      features = document.words.uniq
      pscores = 1
 

### 
#compute weighted probabilities for each word/cat tuple
#and then multiply them all together...
##



      features.each do |word|
        clf = word_prob(category, word)
        freqsum = @categories.reduce(0) {|sum, x| sum + word_prob(x, word)}
        pscores *= (clf / freqsum) if clf > 0
      end
  
#####


#compute fisher factor of pscores
      score = -2 * Math.log(pscores)

#this is okay
      invchi2(score, features.count * 2)
    end
  
    def word_prob(cat, word)
      @category_counts[cat][word].to_f / @document_counts[cat]  
    end
  
    def invchi2(chi, df)
      m = chi / 2.0
      sum = Math.exp(-m)
      term = Math.exp(-m)
  
      (1..df/2).each do |i|
        term *= (m / i)
        sum += term
      end
  
      [sum, 1.0].min 
      
    rescue
      1.0 
    end
  end

end
