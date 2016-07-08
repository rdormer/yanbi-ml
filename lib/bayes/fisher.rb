# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2016 Robert Dormer
# License::   MIT

module Yanbi

  class Fisher < Bayes
   
    private
  
    def score(category, document)
      features = document.words.uniq
      probs = features.map {|x| weighted_prob(x, category)}
      pscores = probs.reduce(&:*)
      score = -2 * Math.log(pscores)
      invchi2(score, features.count * 2)
    end

    def category_prob(cat, word)
      wp = word_prob(cat, word)
      sum = @categories.inject(0) {|s,c| s + word_prob(c, word)}
      return 0 if sum.zero?
      wp / sum
    end

    def word_prob(cat, word)
      count = @category_counts[cat].has_key?(word) ? @category_counts[cat][word].to_f : 0 
      count / @category_sizes[cat]
    end

    def weighted_prob(word, category, basicprob=nil, weight=1.0, ap=0.5)
      basicprob = category_prob(category, word)
      totals = @category_counts.inject(0) {|sum, cat| sum += cat.last[word].to_i}
      ((weight * ap) + (totals*basicprob)) / (weight + totals)
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
