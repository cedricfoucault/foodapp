// --------------------- Sketch-wide variables ----------------------

StackedBarChart stackedBarChart;
PFont titleFont,smallFont;
PGraphics pg;

HashMap menus = new HashMap();
HashMap goals = new HashMap();

// constants
final int TITLE_HEIGHT = 30; // height of the title box above every chart
final int MENU_HEIGHT = 60; // chart height depends on #menus
final int CELL_BOTTOM_PADDING = 20; // add some vertical space
                                    // between each chart
final int CELL_RIGHT_PADDING = 20; // add some horizontal space
                                   // between each chart
final int LEGEND_BOX_HEIGHT = 30;
final int LEGEND_BOTTOM_PADDING = 20;
final int LEGEND_MENU_RECT_SIZE = 18;
final int LEGEND_MENU_TEXT_PADDING = 10;
final int LEGEND_MENU_TEXT_WIDTH = 160;
final int LEGEND_MENU_LEFT_PADDING = 20;


// variables
int canvasWidth = 970; // the width of the whole drawing canvas
                       // dynamically set from javascript
int nColumns = 3; // number of charts to display on one row
                  // depends on the zoom level
                  
ColourTable cTable = new ColourTable().getPresetColourTable(ColourTable.SET1_9);

// --------------------- PJS functions ----------------------

void addMenu(Menu menu) {
  menus.put(menu.cid, menu);
  /*println("added menu");*/
  redraw();
}

void addGoal(Goal goal) {
  goals.put(goal.cid, goal);
  /*println("added goal");*/
  redraw();
}

void removeMenu(String cid) {
  menus.remove(cid);
  /*println("removed menu");*/
  redraw();
}

void removeGoal(String cid) {
  goals.remove(cid);
  /*println("removed goal");*/
  redraw();
}

HashMap getMenus() {
  return menus;
}

HashMap getGoals() {
  return goals;
}

void zoomIn() {
    if (nColumns > 1){
        nColumns--;
        if (nRows() > 3){
            nColumns++;
        } else {
            redraw();
        }
    }
}

void zoomOut() {
    if (nColumns < 8){
        nColumns++;
        redraw();
    }
}

// --------------------- size calculations ----------------------

int setCanvasWidth(int width) {
    canvasWidth = width;
    size(canvasWidth, canvasHeight());
    redraw();
}

int setNColumns(int n) {
    nColumns = n;
    size(canvasWidth, canvasHeight());
    redraw();
}

int canvasHeight() {
    return legendHeight() + cellHeight() * nRows();
}

int nRows() {
    /*return 2 / nColumns;*/
    return ceil((float)goals.size() / (float)nColumns);
}

int cellHeight() {
    return TITLE_HEIGHT + chartHeight() + CELL_BOTTOM_PADDING;
}

int chartHeight() {
    /*return 3 * MENU_HEIGHT;*/
    return menus.size() * MENU_HEIGHT;
}

int cellWidth() {
    return canvasWidth / nColumns;
}

int chartWidth() {
    return cellWidth() - CELL_RIGHT_PADDING;
}

int legendMenuWidth() {
    return LEGEND_MENU_LEFT_PADDING + LEGEND_MENU_RECT_SIZE + LEGEND_MENU_TEXT_PADDING + LEGEND_MENU_TEXT_WIDTH;
}

int legendHeight() {
    return LEGEND_BOX_HEIGHT + LEGEND_BOTTOM_PADDING;
}

int legendBoxWidth() {
    return menus.size() * legendMenuWidth();
}

// --------------------- helper functions ----------------------

public class CIDQuicksort  { // singleton class to sort arrays of cIDs hash keys
  private String[] cids;
  private int number;

  public void sort(String[] cids) {
    // check for empty or null array
    if (cids ==null || cids.length==0){
      return;
    }
    this.cids = cids;
    number = cids.length;
    quicksort(0, number - 1);
  }

  private void quicksort(int low, int high) {
    int i = low, j = high;
    // Get the pivot element from the middle of the list
    String pivot = this.cids[low + (int)((high-low)/2)];
    
    // Divide into two lists
    while (i <= j) {
      // If the current value from the left list is smaller then the pivot
      // element then get the next element from the left list
      while (compare(this.cids[i], pivot) < 0) {
        i++;
      }
      // If the current value from the right list is larger then the pivot
      // element then get the next element from the right list
      while (compare(this.cids[j], pivot) > 0) {
        j--;
      }

      // If we have found a values in the left list which is larger then
      // the pivot element and if we have found a value in the right list
      // which is smaller then the pivot element then we exchange the
      // values.
      // As we are done we can increase i and j
      if (i <= j) {
        exchange(i, j);
        i++;
        j--;
      }
    }
    // Recursion
    if (low < j)
      quicksort(low, j);
    if (i < high)
      quicksort(i, high);
  }

  private void exchange(int i, int j) {
    String temp = this.cids[i];
    this.cids[i] = cids[j];
    this.cids[j] = temp;
  }
  
  private int compare(String cid1, String cid2) {
      /*println(cid1);*/
      /*println(cid2);*/
      int i1 = (int)cid1.substring(1);
      int i2 = (int)cid2.substring(1);
      /*println(i1);*/
      /*println(i2);*/
      return i1 - i2;
  }
}

CIDQuicksort cidQuicksort = new CIDQuicksort();

String[] keysSorted(HashMap map) {
  Set<String> keys = map.keySet();
  String[] keysSorted = new String[map.size()];
  int i = 0;
  for (String key : keys) {
      keysSorted[i] = key;
      i++;
  }
  /*println(i);*/
  /*println(map.size())*/
  /*println(keysSorted);*/
  /*println(keysSorted);*/
  /*Arrays.sort(keysSorted, new CIDComparator());*/
  cidQuicksort.sort(keysSorted);
  return keysSorted;
}

Goal getKthGoal(int k) {
    String[] keys = keysSorted(goals);
    return goals.get(keys[k]);
}

Menu getKthMenu(int k) {
    String[] keys = keysSorted(menus);
    return menus.get(keys[k]);
}

String capitalize(String line) {
    return line.substring(0, 1).toUpperCase() + line.substring(1);
}

// ------------------------ Initialisation --------------------------

// Initialises the data and bar chart.
public void setup() {
  /*size(1,100);*/
  /*size(canvasWidth, canvasHeight());*/
  background(0);
  smooth();
//  titleFont = loadFont("Helvetica-22.vlw");
//  smallFont = loadFont("Helvetica-12.vlw");  
  /*titleFont = createFont("Helvetica", 22);*/
  titleFont = createFont("Arial", 20);
  smallFont = createFont("Arial", 12);
  
  /*float[][] values = new float[][] {{676.5f,517f,609.9f}, {564f, 517f, 368.4f, 862.5f}, {1113f, 1092f}};
  String[][] names = new String[][] {{"Ham & Eggs", "Chicken Salad", "Tuna & Pasta"}, {"Continental Breakfast", "Chicken Salad", "Bread+Marmalade", "Noodle Soup"}, {"KFC", "McDonald's"}}; 

  float[] colourData = new float[] {1, 2, 3};

  stackedBarChart = new StackedBarChart(this, pg);
  stackedBarChart.setData(values);
  stackedBarChart.setNames(names);
  stackedBarChart.setBarLabels(new String[] {"Plan 1","Plan 2","Plan 3"});
  stackedBarChart.setBarColour(colourData, cTable);
  stackedBarChart.setBarGap(0);
  stackedBarChart.setValueFormat(1);*/
  /*stackedBarChart.setValueAxisLabel("kcal");*/
  /*stackedBarChart.setCategoryFormat("Plan #");*/
  /*stackedBarChart.setCategoryFormat(1);
  stackedBarChart.showValueAxis(true); 
  stackedBarChart.showCategoryAxis(false);
  stackedBarChart.setShowEdge(true);
  stackedBarChart.transposeAxes(true);
  stackedBarChart.setRefValue(2100);
  stackedBarChart.setMinValue(0);*/
    noLoop();
}

// ------------------ Processing draw --------------------

// Draws the graph in the sketch.
public void draw() {
    if (goals.size() > 0){
        size(canvasWidth, canvasHeight());
        pg = createGraphics(canvasWidth, canvasHeight());
        pg.beginDraw();
        pg.background(255);
        // draw the legend
        drawLegend();
        // draw every cell
        for (int i = 0; i < nRows(); i++){
            for (int j = 0; j < nColumns; j++){
              int k = i * nColumns + j;
              if (k >= goals.size()){
                  // stop here if no more chart to draw
                  break;
              }
              drawCell(i, j);
            }
        }
        pg.endDraw();
        image(pg, 0, 0);
    } else {
        size(1, 1);
    }
  
  /*pg.pushStyle()
  pg.textFont(titleFont);
  pg.stroke(0);
  pg.fill(0);
  pg.textAlign(LEFT, TOP);
  pg.text("Title", 0, 0, cellWidth(), TITLE_HEIGHT);
  pg.popStyle();
  textFont(smallFont);
  stackedBarChart.draw(0, TITLE_HEIGHT, chartWidth(), chartHeight());*/
  
  /*stackedBarChart.draw(width / 2, 0, width / 2, height);*/
//    fill(120);
//    textFont(titleFont);
//    text("Income per person, United Kingdom", 70,30);
//    float textHeight = textAscent();
//    textFont(smallFont);
//    text("Gross domestic product measured in inflation-corrected $US", 70,30+textHeight);
}

void drawLegend() {
    if (menus.size() > 0){
        pg.pushStyle();
        pg.textFont(smallFont);
        pg.textAlign(LEFT, CENTER);
        // draw the legend box
        pg.stroke(0);
        pg.fill(255);
        pg.rect(0, 0, legendBoxWidth(), LEGEND_BOX_HEIGHT);
        String[] menuKeys = keysSorted(menus);
        for (int i = 0; i < menus.size(); i++){
            int left = i * legendMenuWidth();
            // draw the colored rectangle
            float rectColor = cTable.findColour(i + 2);
            pg.fill(rectColor);
            pg.rect(left + LEGEND_MENU_LEFT_PADDING, (LEGEND_BOX_HEIGHT - LEGEND_MENU_RECT_SIZE) / 2, LEGEND_MENU_RECT_SIZE, LEGEND_MENU_RECT_SIZE);
            // draw the caption
            String caption = menus.get(menuKeys[i]).name;
            pg.fill(0);
            pg.text(caption, left + LEGEND_MENU_LEFT_PADDING + LEGEND_MENU_RECT_SIZE + LEGEND_MENU_TEXT_PADDING, 0, LEGEND_MENU_TEXT_WIDTH, LEGEND_BOX_HEIGHT);
        }
        pg.popStyle();
    }
}

void drawCell(int i, int j) {
    int left = j * cellWidth();
    int top = legendHeight() + i * cellHeight();
    // get corresponding goal
    int k = i * nColumns + j;
    Goal goal = getKthGoal(k);
    if (goal.nutrient) {
        // draw the title
        String title = goal.nutrientName + " (" + goal.unit + ")";
        pg.pushStyle();
        pg.textFont(titleFont);
        pg.stroke(0);
        pg.fill(0);
        pg.textAlign(LEFT, TOP);
        pg.text(capitalize(title), left, top, cellWidth(), TITLE_HEIGHT);
        pg.popStyle();
        // setup the chart
        int nMenus = menus.size();
        float[][] values = new float[nMenus][];
        String[][] ingredientNames = new String[nMenus][];
        String[] menuKeys = keysSorted(menus);
        float[] colourData = new float[nMenus];
        for (int i = 0; i < nMenus; i++){
            Menu menu = menus.get(menuKeys[i]);
            int nIngredients = menu.ingredients.size();
            values[i] = new float[nIngredients]
            ingredientNames[i] = new String[nIngredients];
            colourData[i] = i + 2;
        
            String[] ingredientKeys = keysSorted(menu.ingredients);
            for (int j = 0; j < nIngredients; j++){
                Ingredient ingredient = menu.ingredients.get(ingredientKeys[j]);
                ingredientNames[i][j] = ingredient.food.get("long_description");
                /*println(ingredient.food["short_description"]);*/
                /*println(ingredientNames[i][j]);*/
                values[i][j] = ingredient.food.get(goal.nutrient) * ingredient.amount / (100.0f * menu.amount);
                /*for (String key : ingredient.food.keySet()) {
                    println(key + " :");
                    println(ingredient.food.get(key));
                }*/
                /*println(values[i][j]);*/
            }
        }
        StackedBarChart chart = new StackedBarChart(this, pg);
        chart.setData(values);
        chart.setNames(ingredientNames);
        chart.setBarColour(colourData, cTable);
        chart.setRefValueColour(cTable.findColour(1));
        chart.setBarGap(0);
        chart.setValueFormat(1);
        /*chart.setValueAxisLabel(goal.unit);*/
        chart.showValueAxis(true); 
        chart.showCategoryAxis(false);
        /*chart.setShowEdge(true);*/
        chart.setShowEdge(false);
        chart.transposeAxes(true);
        chart.setRefValue(goal.value);
        chart.setMinValue(0);
        // draw the chart
        pg.pushStyle()
        textFont(smallFont);
        chart.draw(left, top + TITLE_HEIGHT, chartWidth(), chartHeight());
        pg.popStyle();
    }
}

