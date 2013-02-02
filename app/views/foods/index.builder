xml.foods do
  @foods.each do |food|
    xml << render(partial: 'food', locals: {food: food})
  end
end