public class Goal {
    public String cid;
    public String nutrient;
    public String nutrientName;
    public String unit = "";
    public float value;

    public Goal(String cid) {
        this.cid = cid;
    }

    public void change(String nutrient, float value) {
      this.nutrient = nutrient;
      this.value = value;
      /*println("changed Goal");*/
      redraw();
    }
}
