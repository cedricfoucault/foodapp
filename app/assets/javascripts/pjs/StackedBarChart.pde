import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PVector;

public class StackedBarChart extends AbstractChart {
  
  // The stacked bar chart stores the category index in dimension 0, the colour table
  // in dimension 1, the flattened values in dimension 2, the subcount of each category in dimension 3,
  // the sum values in dimension 4, and the name corresponding to each data in dimension 5;
  
  // ----------------------------- Object variables ------------------------------
    
    private int barColour;                      // Default bar color value
    private int refValueColour;
    private float barGap;                       // Gap between interior bars.
    private float barPad;                       // Symmetrical padding around each bar;
    private float tickLength;                   // Tick marks length
    private boolean reverseCats;
    private ColourTable cTable;
    
    private float refValue;              // Reference value
    private String[] catLabels;                 // Category labels.
    private boolean showLabels;
    private String categoryLabel, valueLabel;   // Axis labels.
    private Float catAxisPosition;              // Position of the category axis (defaults to minumum value).
    private float top,left,bottom,right;        // Bounds of the data area (excludes axes and axis labels).
    private String[][] names;                   // Names associated to each value data
          
    // ------------------------------- Constructors --------------------------------
    
    public StackedBarChart(PApplet parent, PGraphics pg)
    {
        super(parent, pg);
        barGap        = 0;
        barPad        = 14;
        barColour     = color(180);
        refValueColour = color(0);
        reverseCats   = false;
        cTable        = null;
        catLabels     = null;
        showLabels    = false;
        categoryLabel = null;
        valueLabel    = null;
        transposeAxesBool = true;
        top           = 0;
        bottom        = 0;
        left          = 0;
        right         = 0;
        refValue = 0;
        tickLength = 10;
        names = null;
//        minBorder = 0;
    }
    
    // ---------------------------------- Methods ----------------------------------
    
    public float log10 (int x) {
      return (log(x) / log(10));
    }
    
    public void setData(float[][] values)
    {
      int nCat = values.length;
      
      int valueCount = 0;
      for (int i=0; i < nCat; i++) {
        valueCount += values[i].length;
        }
      
      float[] valuesFlattened = new float[valueCount];
      float[] subCounts = new float[nCat];
      float[] sumValues = new float[nCat];
      int k = 0;
      for (int i=0; i < nCat; i++) {
        int subCount = values[i].length;
        subCounts[i] = subCount;
        
        float sumValue = 0.f;
        for (int j=0; j < subCount; j++) {
          sumValue += values[i][j];
          valuesFlattened[k] = values[i][j];
          k++;
        }
        sumValues[i] = sumValue;
        }
      
      setData(2, valuesFlattened);
      setData(3, subCounts);
      setData(4, sumValues);
      
      
      if (getData(0) == null) {
        float[] categories = new float[nCat];
            for (int i=0; i < nCat; i++) {
                categories[i] = i+1;
            }
            setData(0,categories);
      }       
        
    }
    
    public void setNames(String[][] names) {
      int valueCount = 0;
      for (int i=0; i < names.length; i++) {
        valueCount += names[i].length;
        }
      if (valueCount != data[2].length) {
        println("Warning: Number of items in names data ("+names.length+") does not match number of bars ("+data[2].length+").");
            return;
      }
      
      this.names = names;
    }
    
    public void setBarLabels(String[] labels) {
        if (labels == null)
        {
            showLabels = false;
           
            if (getShowAxis(0))
            {
                // This will recalculate appropriate border now we are not showing labels.
                setMinBorder(0, transposeAxesBool?Side.LEFT:Side.BOTTOM);
                showAxis(0, true, transposeAxesBool?Side.LEFT:Side.BOTTOM);
            }
            return;
        }
        
        if (labels.length != data[0].length)
        {
            /*println("Warning: Number of labels ("+labels.length+") does not match number of bars ("+data[0].length+").");*/
            return;
        }
        
        this.catLabels = labels;
        showLabels = true;
        
        float border = getMinBorder();
        
        if (transposeAxesBool)
        {
            // Bar labels are up the side.
            for (String label : labels)
            {
                border = Math.max(border, graphics.textWidth(label));
            }
            setMinBorder(border+2,Side.LEFT);
        } 
    }
    
    public void setRefValueColour(int colour) {
        refValueColour = colour;
    }
  
    public void draw(float xOrigin, float yOrigin, float width, float height) {
        if ((data[2] == null) || (data[2].length==0)) {
            return;
        }
        
        // Sore stroke colour in case it is needed for brawing edges around bars.
        int strokeColour = graphics.strokeColor;
        
        graphics.pushStyle();
        
        // Extra spacing required to fit axis labels. This can't be handled by the AbstractChart
        // because not all charts label their axes in the same way.
        float extraLeftBorder   = 2;
        float extraRightBorder  = 2;
        float extraTopBorder    = 2;
        float extraBottomBorder = 2;
         
        // Allow space to the right of the horizontal axis to accommodate right-hand tic label.
        if ((getShowAxis(0)) || ((transposeAxesBool) && (getShowAxis(4)))) {
            int axis = transposeAxesBool?4:0;
            String lastLabel;
            if ((catLabels != null) && (!transposeAxesBool))
            {
                lastLabel = catLabels[catLabels.length-1];
            }
            else
            {
                lastLabel = nfc(tics[axis][tics[axis].length-1], rightDigits[axis]);
            }
            extraRightBorder += graphics.textWidth(lastLabel)/2f;
        }
        
        // Allow space above the vertical axis to accommodate the top tic label.
        if ((getShowAxis(4)) || ((transposeAxesBool) && (getShowAxis(0)))) {   
            /*extraTopBorder += graphics.textAscent()/2f+2;*/
        }
        
        // Allow space to the left of the vertical axis to accommodate its label.
        if (((valueLabel != null) && getShowAxis(4)) || ((transposeAxesBool) && (categoryLabel != null) && getShowAxis(0))) {
            /*extraLeftBorder += graphics.textAscent()+graphics.textDescent();*/
        }
        
        // Allow space below the horizontal axis to accommodate its label.
        if (((categoryLabel != null) && getShowAxis(0)) || ((transposeAxesBool) && (valueLabel != null) && getShowAxis(4))) {
            extraBottomBorder +=graphics.textAscent()+graphics.textDescent();
        }  
        
        left   = xOrigin + getBorder(Side.LEFT) + extraLeftBorder;
        right  = xOrigin + width - (getBorder(Side.RIGHT)+extraRightBorder);
        bottom = yOrigin + height-(getBorder(Side.BOTTOM)+extraBottomBorder);
        top    = yOrigin + getBorder(Side.TOP)+extraTopBorder;
        float hRange = right-left;
        float vRange = bottom-top;
        float axisValue;
        if (catAxisPosition == null) {
            // Default value axis is at the lowest value.
            axisValue = getMin(4);
        }
        else {
            axisValue = catAxisPosition.floatValue();
        }
        
        float barWidth;
        float maxValue = getMaxValue();
        float maxLogValue = getMaxLogValue();
        
        if (drawDecorations) {
            if (getShowAxis(4)) {  // Value axis.
                /*graphics.strokeWeight(0.5f);*/
                graphics.stroke(axisColour);
            
                if (transposeAxesBool) {
                  graphics.line(left,bottom,right,bottom);
                } else {
                  graphics.line(left,bottom,left,top);
                }
            
                // Draw axis values and reference value
                graphics.fill(axisValuesColour);
                if (getIsLogScale(4)) {                         
                    for (float logTic : logTics[4]) {
                        float tic = (float)Math.pow(10,logTic);
                        if (tic <= maxValue) {
                            if (transposeAxesBool) {
                                graphics.textAlign(CENTER, TOP);
                                graphics.text(nfc(tic, rightDigits[4]),left +hRange*(logTic-getMinLog(4))/(maxLogValue-getMinLog(4)),bottom+2);
                                // tick mark
                                graphics.stroke(tickColour);
                                graphics.line(left+hRange*(logTic-getMinLog(4))/(maxLogValue-getMinLog(4)), bottom, left +hRange*(logTic-getMinLog(4))/(maxLogValue-getMinLog(4)), top);
                                /*graphics.line(left +hRange*(logTic-getMinLog(4))/(maxLogValue-getMinLog(4)), bottom, left +hRange*(logTic-getMinLog(4))/(maxLogValue-getMinLog(4)), bottom - tickLength);*/
                            } else {
                                graphics.textAlign(RIGHT, CENTER);
                                graphics.text(nfc(tic, rightDigits[4]),left-2,top +vRange*(maxLogValue-logTic)/(maxLogValue-getMinLog(4)));
                                // tick mark
                                graphics.stroke(tickColour);
                                graphics.line(left, top+vRange*(maxLogValue-logTic)/(maxLogValue-getMinLog(4)), right, top +vRange*(maxLogValue-logTic)/(maxLogValue-getMinLog(4)));
                                /*graphics.line(left, top +vRange*(maxLogValue-logTic)/(maxLogValue-getMinLog(4)), left + tickLength, top +vRange*(maxLogValue-logTic)/(maxLogValue-getMinLog(4)));*/
                            }
                        }
                    }
                    // ref value
                    /*graphics.strokeWeight(1f);*/
                    graphics.stroke(refValueColour);
                    graphics.fill(refValueColour);
                    if (refValue <= maxValue) {
                        if (transposeAxesBool) {
                            graphics.textAlign(CENTER, TOP);
                            graphics.text(nfc(refValue, rightDigits[4]),left +hRange*((float)log10(refValue)-getMinLog(4))/(maxLogValue-getMinLog(4)),bottom+2);
                            // tick mark
                            graphics.line(left +hRange*((float)log10(refValue)-getMinLog(4))/(maxLogValue-getMinLog(4)), bottom, left +hRange*((float)log10(refValue)-getMinLog(4))/(maxLogValue-getMinLog(4)), top);
                        } else {
                            graphics.textAlign(RIGHT, CENTER);
                            graphics.text(nfc(refValue, rightDigits[4]),left-2,top +vRange*(maxLogValue-(float)log10(refValue))/(maxLogValue-getMinLog(4)));
                            // tick mark
                            graphics.line(left, top +vRange*(maxLogValue-(float)log10(refValue))/(maxLogValue-getMinLog(4)), right, top +vRange*(maxLogValue-(float)log10(refValue))/(maxLogValue-getMinLog(4)));
                        }
                    }
                } else {
                    for (float tic : tics[4]) {
                        if (tic <= maxValue) {
                            if (transposeAxesBool) {
                                graphics.textAlign(CENTER, TOP);
                                graphics.text(nfc(tic, rightDigits[4]),left +hRange*(tic-getMin(4))/(maxValue-getMin(4)),bottom+2);
                                // tick mark
                                graphics.stroke(tickColour);
                                graphics.line(left+hRange*(tic-getMin(4))/(maxValue-getMin(4)), bottom, left +hRange*(tic-getMin(4))/(maxValue-getMin(4)), top);
                                /*graphics.line(left +hRange*(tic-getMin(4))/(maxValue-getMin(4)), bottom, left +hRange*(tic-getMin(4))/(maxValue-getMin(4)), bottom - tickLength);*/
                            } else {
                                graphics.textAlign(RIGHT, CENTER);
                                graphics.text(nfc(tic, rightDigits[4]),left-2,top +vRange*(maxValue-tic)/(maxValue-getMin(4)));
                                // tick mark
                                graphics.stroke(tickColour);
                                graphics.line(left, top+vRange*(maxValue-tic)/(maxValue-getMin(4)), right, top +vRange*(maxValue-tic)/(maxValue-getMin(4)));
                                /*graphics.line(left, top +vRange*(maxValue-tic)/(maxValue-getMin(4)), left + tickLength, top +vRange*(maxValue-tic)/(maxValue-getMin(4)));*/
                            }
                        }
                    }
              // ref value
              /*graphics.strokeWeight(1f);*/
              graphics.stroke(refValueColour);
              graphics.fill(refValueColour);
              if (refValue <= maxValue) {
                if (transposeAxesBool) {
                graphics.textAlign(CENTER, TOP);
                graphics.text(nfc(refValue, rightDigits[4]),left +hRange*(refValue-getMin(4))/(maxValue-getMin(4)),bottom+2);
                // tick mark
                graphics.line(left +hRange*(refValue-getMin(4))/(maxValue-getMin(4)), bottom, left +hRange*(refValue-getMin(4))/(maxValue-getMin(4)), top);
                } else {
                graphics.textAlign(RIGHT, CENTER);
                graphics.text(nfc(refValue, rightDigits[4]),left-2,top +vRange*(maxValue-refValue)/(maxValue-getMin(4)));
                // tick mark
                graphics.line(left, top +vRange*(maxValue-refValue)/(maxValue-getMin(4)), right, top +vRange*(maxValue-refValue)/(maxValue-getMin(4)));
                }
            }
            }
            /*graphics.strokeWeight(0.5f);*/
            graphics.stroke(axisColour);
            graphics.fill(axisValuesColour);

            // Draw axis label if requested.
            if (valueLabel != null) {
                graphics.fill(axisLabelColour);
                if (transposeAxesBool) {
                graphics.textAlign(CENTER,TOP);
                graphics.text(valueLabel,(left+right)/2f,bottom+getBorder(Side.BOTTOM)+2);
                } else {
                graphics.textAlign(CENTER,BOTTOM);
                // Rotate label.
                graphics.pushMatrix();
                graphics.translate(left-(getBorder(Side.LEFT)+1),(top+bottom)/2f);
                graphics.rotate(-HALF_PI);
                graphics.text(valueLabel,0,0);
                graphics.popMatrix();
                }
            }
        }
        
        if (transposeAxesBool) {
            barWidth = (vRange - (data[0].length-1)*barGap - data[0].length*barPad) / data[0].length;    
        }
        else {
            barWidth = (hRange - (data[0].length-1)*barGap - data[0].length*barPad) / data[0].length;    
        }
       
        if (showEdge) {
            graphics.stroke(strokeColour);
        }
        else {
            graphics.stroke(255);
        }
        
        float[][] values = get2DValues();
        float[] colors = data[1];
        for (int index=0; index < data[0].length; index++) {
            int i = reverseCats?(data[0].length-1-index):index;
            float startValue = 0f;
            for (int j = 0; j < values[i].length; j++) {
                float dataValue = Math.max(Math.min(data[1][index],getMax(1)),getMin(1));
                float dataValue = values[i][j];
                // draw bars
                if (cTable != null) {
                    graphics.fill(cTable.findColour(colors[i]));
                } else {
                    graphics.fill(barColour);
                    
                }
                if (transposeAxesBool) {
                    if (getIsLogScale(4)) {
                        graphics.rect(left + hRange*convertToLog(startValue,getMinLog(4),maxLogValue), top + i*(barWidth+barGap+barPad)+barPad/2f, hRange*convertToLog(dataValue,getMinLog(4),maxLogValue),barWidth);
                    } else { graphics.rect(left+(hRange*(startValue+axisValue-getMin(4))/(maxValue-getMin(4))), top + i*(barWidth+barGap+barPad)+barPad/2f, hRange*(dataValue-axisValue)/(maxValue-getMin(4)),barWidth);
                    }
                } else {
                    if (getIsLogScale(4)) {
                    graphics.rect(left + i*(barWidth+barGap+barPad)+barPad/2f, bottom-vRange*convertToLog(startValue,getMinLog(4),maxLogValue) , barWidth, -vRange*convertToLog(dataValue,getMinLog(4),maxLogValue));
                    } else {
                    graphics.rect(left + i*(barWidth+barGap+barPad)+barPad/2f, bottom-(vRange*(startValue+axisValue-getMin(4))/(maxValue-getMin(4))), barWidth, -vRange*(dataValue-axisValue)/(maxValue-getMin(4)));
                    }
                }
                // draw text
                if (names != null) {
                    graphics.fill(0);
                    graphics.textAlign(CENTER, CENTER);
                    if (transposeAxesBool) {
                        if (getIsLogScale(4)) {
                          graphics.text(names[i][j], left + hRange*convertToLog(startValue,getMinLog(4),maxLogValue) + 1, top + i*(barWidth+barGap+barPad)+barPad/2f + 1, hRange*convertToLog(dataValue,getMinLog(4),maxLogValue) - 2, barWidth - 2);
                        } else {
                          graphics.text(names[i][j], left + (hRange*(startValue+axisValue-getMin(4))/(maxValue-getMin(4))) + 1, top + i*(barWidth+barGap+barPad)+barPad/2f + 1, hRange*(dataValue-axisValue)/(maxValue-getMin(4)) - 2, barWidth - 2);
                        }
                    } else {
                        if (getIsLogScale(4)) {
                            graphics.text(names[i][j], left + i*(barWidth+barGap+barPad)+barPad/2f + 1, bottom-vRange*convertToLog(startValue,getMinLog(4),maxLogValue) + 1, barWidth - 2, -vRange*convertToLog(dataValue,getMinLog(4),maxLogValue) - 2);
                        } else {
                            graphics.text(names[i][j], left + i*(barWidth+barGap+barPad)+barPad/2f + 1, bottom-(vRange*(startValue+axisValue-getMin(4))/(maxValue-getMin(4))) + 1, barWidth - 2, -vRange*(dataValue-axisValue)/(maxValue-getMin(4))) - 2;
                        }
                    }
                }
                startValue += dataValue;
            }
        }

          if (getShowAxis(0))  // Category axis.
          {
            /*graphics.strokeWeight(0.5f);*/
            graphics.stroke(axisColour);
            graphics.fill(axisValuesColour);
            for (int i=0; i<data[0].length; i++)
            {
              if (transposeAxesBool)
              {
                graphics.textAlign(RIGHT, CENTER); 
                int index = reverseCats?(data[0].length-1-i):i;
                if (showLabels == false)
                {
                  graphics.text(nfc(data[0][index], rightDigits[0]),left-2,top+barWidth/2f + i*(barWidth+barGap+barPad));
                }
                else
                {
                  graphics.text(catLabels[index],left-2,top+barWidth/2f + i*(barWidth+barGap+barPad));
                }
                graphics.line(left, top, left, bottom);
              }
              else
              {
                graphics.textAlign(CENTER, TOP); 
                int index = reverseCats?(data[0].length-1-i):i;
                if (showLabels == false)
                {
                  graphics.text(nfc(data[0][index], rightDigits[0]),left+barWidth/2f + i*(barWidth+barGap+barPad),bottom+2);
                }
                else
                {
                  graphics.text(catLabels[index],left+barWidth/2f + i*(barWidth+barGap+barPad),bottom+2);
                }
                graphics.line(left, bottom, right, bottom);
              }
            }

            // Draw axis label if requested
            if (categoryLabel != null)
            {
              graphics.fill(axisLabelColour);
              if (transposeAxesBool)
              {
                graphics.textAlign(CENTER,BOTTOM);
                // Rotate label.
                graphics.pushMatrix();
                graphics.translate(left-(getBorder(Side.LEFT)+1),(top+bottom)/2f);
                graphics.rotate(-HALF_PI);
                graphics.text(categoryLabel,0,0);
                graphics.popMatrix();
              }
              else
              {
                graphics.textAlign(CENTER,TOP);
                graphics.text(categoryLabel,(left+right)/2f,bottom+getBorder(Side.BOTTOM)+2);
              }
            }
          }
        }
        
        // draw line for reference value
        /*graphics.strokeWeight(1f);*/
        /*graphics.stroke(0);
        if (refValue > 0) {
          if (transposeAxesBool) {
                if (getIsLogScale(4)) {
                  graphics.line(left + hRange*convertToLog(refValue,getMinLog(4),maxLogValue), top, left + hRange*convertToLog(refValue,getMinLog(4),maxLogValue), bottom);
                }
                else {
                  graphics.line(left + (hRange*(refValue+axisValue-getMin(4))/(maxValue-getMin(4))), top, left + (hRange*(refValue+axisValue-getMin(4))/(maxValue-getMin(4))), bottom);
                }
            } else {
              if (getIsLogScale(4)) {
                graphics.line(left, bottom-vRange*convertToLog(refValue,getMinLog(4),maxLogValue), right, bottom-vRange*convertToLog(refValue,getMinLog(4),maxLogValue));
                }
                else {
                  graphics.line(left, bottom-(vRange*(refValue+axisValue-getMin(4))/(maxValue-getMin(4))), right, bottom-(vRange*(refValue+axisValue-getMin(4))/(maxValue-getMin(4))));
                }
            }
        }*/
        
        graphics.popStyle();
    }
  
    public PVector getDataToScreen(PVector dataPoint)
    {
        float hRange = right-left;
        float vRange = bottom-top;
        
        if ((vRange <= 0) || (hRange <=0))
        {
            return null;
        }
        
        float x,y;
        
        //Scale data points between 0-1.
        x = dataPoint.x/(data[0].length-1);

        if (getIsLogScale(4))
        {
            y = convertToLog(dataPoint.y, getMinLog(4), getMaxLogValue());
        }
        else
        {
            y = (dataPoint.y-getMin(4))/(getMaxValue()-getMin(4));
        }
        
        if (transposeAxesBool)
        {
            float barWidth = (vRange - (data[0].length-1)*barGap - data[0].length*barPad) / data[0].length;   
            return new PVector(left + hRange*y, bottom - barWidth/2f - barPad/2f - (vRange-barWidth-barPad)*x);
        }
        
        float barWidth = (hRange - (data[0].length-1)*barGap - data[0].length*barPad) / data[0].length;    
        return new PVector(left + barPad/2f + barWidth/2f + (hRange-barWidth-barPad)*x, bottom - vRange*y);
    }
    
    /** Converts given screen coordinate into its equivalent data value. This value will
     *  be based on the last time the data were drawn with the <code>draw()</code> method. 
     *  If this is called before any call to <code>draw()</code> has been made, it will return null.
     *  The x-value of the returned data point corresponds to the zero-indexed counter of the number
     *  of bars (i.e if the screen location falls within the first bar, the x-value will be 0, if
     *  it falls within the second 1 will be returned etc.).
     *  @param screenPoint Screen coordinates to convert into data pair.
     *  @return (x,y) pair representing an item of data that would be displayed at the given screen
     *          location or null if screen space not defined or screenPoint is outside of the 
     *          visible chart space.
     */
    public PVector getScreenToData(PVector screenPoint)
    {
        float hRange = right-left;
        float vRange = bottom-top;
        
        if ((vRange <= 0) || (hRange <=0))
        {
            return null;
        }
        
        if ((screenPoint.x < left) || (screenPoint.x >= right) || (screenPoint.y <= top) || (screenPoint.y > bottom))
        {
            return null;
        }
        
        // Scale the screen coordinates between 0-1.
        float x,y;
        if (transposeAxesBool)
        {
            y = (screenPoint.x - left)/(hRange);
            x = (bottom - screenPoint.y)/vRange;
        }
        else
        {   
            x = (screenPoint.x - left)/(hRange);
            y = (bottom - screenPoint.y)/vRange;
        }
        
        x = (int)(x*data[0].length);
        
        if (getIsLogScale(4))
        {
            y = convertFromLog(y, getMinLog(4), getMaxValue());
        }
        else
        {
            y = y*(getMaxValue()-getMin(4)) + getMin(4);
        }
        
        return new PVector(x,y);
    }
    
    /** Reports the number of bars in the bar chart. This value will include any bars that
     *  happen to have a height of 0.
     *  @return Number of bars in the bar chart.
     */
    public int getNumBars()
    {
        return data[0].length;
    }
    
    /** Determines whether or not the values represented by the length of each bar should be log10-scaled.
     *  @param isLog True if values are to be log10-scaled or false if linear.
     */
    public void setLogValues(boolean isLog)
    {
        setIsLogScale(4, isLog);
    }

    /** Sets the minimum value for the bar chart. Can be used to ensure multiple charts
     *  can share the same origin. If the given value is <code>Float.NaN</code>, then 
     *  the minimum value will be set to the minimum of the data values in the chart.
     *  @param minVal Minimum value to use for scaling bar lengths or <code>Float.NaN</code> 
     *                if data minimum is to be used.
     */
    public void setMinValue(float minVal)
    {
       setMin(4,minVal);
    }
    
    /** Reports the minimum value that can be displayed by the bar chart. Note that this need not
     *  necessarily be the same as the minimum data value being displayed since axis rounding or
     *  calls to <code>setMinValue()</code> can affect the value.
     *  @return Minimum value that can be represented by the bar chart.
     */
    public float getMinValue()
    {
        return getMin(4);
    }
    
    /** Reports the maximum value that can be displayed by the bar chart. Note that this need not
     *  necessarily be the same as the maximum data value being displayed since axis rounding or
     *  calls to <code>setMaxValue()</code> can affect the value.
     *  @return Maximum value that can be represented by the bar chart.
     */
    public float getMaxValue() {
      float maxValue = Math.max(refValue, getMax(4));
        return maxValue;
    }
    
    public float getMaxLogValue() {
      float maxValue = Math.max((float)log10(refValue), getMaxLog(4));
        return maxValue;
    }
    
    /** Sets the maximum value for the bar chart. Can be used to ensure multiple charts
     *  are scaled to the same maximum. If the given value is <code>Float.NaN</code>, then 
     *  the maximum value will be set to the maximum of the data values in the chart.
     *  @param maxVal Maximum value to use for scaling bar lengths or <code>Float.NaN</code> 
     *                if data minimum is to be used.
     */
    public void setMaxValue(float maxVal) {
       setMax(4,maxVal);
    }
  
    public void showValueAxis(boolean showAxisArray)
    {
        super.showAxis(4,showAxisArray,transposeAxesBool?Side.BOTTOM:Side.LEFT);
    }
    
    /** Determines whether or not the category axis is drawn.
     *  @param showAxisArray Category axis is drawn if true.
     */
    public void showCategoryAxis(boolean showAxisArray)
    {
        super.showAxis(0,showAxisArray,transposeAxesBool?Side.LEFT:Side.BOTTOM);
        
        if (showAxisArray && showLabels)
        {
            // Need to recalculate space for labels if they are being made to reappear.
            setBarLabels(catLabels);
        }
    }
    
    /** Determines if the axes should be transposed (so that categories appear on the 
     *  vertical axis and values on the horizontal axis).
     *  @param transpose Axes are transposed if true.
     */
    public void transposeAxes(boolean transpose)
    {
        this.transposeAxesBool = transpose;
        
        // This is a bit of a kludge to ensure that new axis borders are calculated
        // when the graph is transposed. By changing the axis visibility and then changing
        // it back again, it ensures the new values are calcualted.
        boolean showCategoryAxisBool = getShowAxis(0);
        boolean showValueAxisBool = getShowAxis(4);
        showCategoryAxis(!showCategoryAxisBool);
        showValueAxis(!showValueAxisBool);
        
        showCategoryAxis(showCategoryAxisBool);
        showValueAxis(showValueAxisBool);
    }
    
    /** Sets the gap between adjacent bars.
     *  @param gap Gap between adjacent bars in pixel units.
     */
    public void setBarGap(float gap)
    {
        this.barGap = gap;
    }
    
    /** Sets the padding between adjacent bars. Unlike barGap, this value will give a 
     *  symmetrical padding around each bar. Can be useful when overlaying bars of 
     *  different thicknesses.
     *  @param padding Padding around bars in pixel units.
     */
    public void setBarPadding(float padding)
    {
        this.barPad = padding;
    }
    
    /** Determines if the order of the category values should be reversed or not.
     *  @param reverse Category order reversed if true.
     */
    public void setReverseCategories(boolean reverse)
    {
        this.reverseCats = reverse;
    }
        
    /** Sets the numerical format for numbers shown on the value axis.
     *  @param format Format for numbers on the value axis.
     */
    public void setValueFormat(int digits)
    {
        setFormat(4, digits);
    }
    
    /** Sets the numerical format for numbers shown on the category axis.
     *  @param format Format for numbers on the category axis.
     */
    public void setCategoryFormat(int digits)
    {
        setFormat(0, digits);
    }
    
    /** Sets the category axis label. If null, no label is drawn.
     *  @param label Category axis label to draw or null if no label to be drawn.
     */
    public void setCategoryAxisLabel(String label)
    {
        this.categoryLabel = label;
    }
    
    /** Sets the value axis label. If null, no label is drawn.
     *  @param label Value-axis label to draw or null if no label to be drawn.
     */
    public void setValueAxisLabel(String label)
    {
        this.valueLabel = label;
    }
    

    public void setRefValue(float ref) {
      this.refValue = ref;
    }
    
    public void setBarColour(int colour)
    {
        this.barColour = colour;
        cTable = null;      // Ignore colour table and data-colour rules.
        data[1] = null;
    }
        
    /** Provides the data and colour table from which to colour bars. Each data item
     *  should by in the same order as the data provided to <code>setData()</code>.
     *  @param colourData Data used to colour bars
     *  @param cTable Colour table that translates data values into colours.
     */
    public void setBarColour(float[] colourData, ColourTable cTable) {
      
      if (colourData.length != data[0].length) {
            println("Warning: Number of items in bar colour data ("+colourData.length+") does not match number of categories ("+data[0].length+").");
            return;
        }
      
      /*int k = 0;
      float[] colourDataFlattened = new float[colourCount];
      for (int i=0; i < colourData.length; i++) {
        for (int j=0; j < colourData[i].length; j++) {
          colourDataFlattened[k] = colourData[i][j];
          k++;
        }
      }*/
      
      // Store colour data in dimension 1 of the chart.
      setData(1, colourData); 
      this.cTable = cTable;
    }
  
  private float[][] get2DValues() {
    float[] flattenedValues = data[2];
    float[][] values = new float[data[0].length][];
    
    int k = 0;
    for (int i = 0; i < data[3].length; i++) {
      int subCount = (int)data[3][i];
      values[i] = new float[subCount];
      for(int j = 0; j < subCount; j++) {
        values[i][j] = flattenedValues[k];
        k++;
      }
    }
    
    return values;
  }
  
  private float[][] get2DArrayFromFlattenedArray(float[] flattened) {
    float[][] array2D = new float[data[0].length][];
    
    int k = 0;
    for (int i = 0; i < data[3].length; i++) {
      int subCount = (int)data[3][i];
      array2D[i] = new float[subCount];
      for(int j = 0; j < subCount; j++) {
        array2D[i][j] = flattened[k];
        k++;
      }
    }
    
    return array2D;
  }

}

