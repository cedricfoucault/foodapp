public class Ingredient {
  public String cid;
  public HashMap food;
  public float amount;
  public String unit;
  
  public Ingredient(String cid) {
    this.cid = cid;
    this.food = new HashMap();
  }
  
  public void change(float amount, String unit) {
      this.amount = amount;
      this.unit = unit;
      /*println("changed ingredient");*/
      redraw();
  }
}

public class Menu {
  public String cid;
  public String name;
  public int amount;
  public HashMap ingredients;
  
  public Menu(String cid, String name, int amount) {
    this.cid = cid
    this.name = name;
    this.amount = amount;
    this.ingredients = new HashMap();
  }
  
  public void addIngredient(Ingredient ingredient) {
    this.ingredients.put(ingredient.cid, ingredient);
    /*println("added ingredient with cid " + ingredient.cid);*/
    redraw();
  }
  
  public void removeIngredient(String cid) {
    this.ingredients.remove(cid);
    /*println("removed ingredient");*/
    redraw();
  }
  
  public Ingredient getIngredient(String cid) {
    return this.ingredients.get(cid);
  }
  
  public void change(String name, int amount) {
      this.name = name;
      this.amount = amount;
      /*println("changed menu");*/
      redraw();
  }
}
