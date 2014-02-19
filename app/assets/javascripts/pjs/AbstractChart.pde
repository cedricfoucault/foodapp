import java.text.DecimalFormat;
import java.util.ArrayList;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PGraphics;

//  ****************************************************************************************
/** Abstract class for representing a statistical chart. This class provides the core 
 *  functionality common to all charts. A chart will contain a set of axes each corresponding
 *  to a set of data. The way in which each axis/data set is displayed will depend on the 
 *  nature of the chart represented by the subclass.
 *  @author Jo Wood, giCentre, City University London.
 *  @version 3.3, 6th April, 2013 
 */ 
// *****************************************************************************************

/* This file is part of giCentre utilities library. gicentre.utils is free software: you can 
 * redistribute it and/or modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3 of the License, or (at your
 * option) any later version.
 * 
 * gicentre.utils is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License along with this
 * source code (see COPYING.LESSER included with this source code). If not, see 
 * http://www.gnu.org/licenses/.
 */

public interface Drawable 
{
        /** Should draw a 2D point at the given coordinates. 
         *  @param x x coordinate of the point.
         *  @param y y coordinate of the point.
         */
        public abstract void point(float x, float y);
        
        /** Should draw a 2D line between the given coordinate pairs. 
         *  @param x1 x coordinate of the start of the line.
         *  @param y1 y coordinate of the start of the line.
         *  @param x2 x coordinate of the end of the line.
         *  @param y2 y coordinate of the end of the line.
         */
        public abstract void line(float x1, float y1, float x2, float y2);
        
        /** Should draw a rectangle using the given location and dimensions. By default the x,y coordinates
         *  will be the top Side.LEFT of the rectangle, but the meanings of these parameters should be able to 
         *  be changed with Processing's rectMode() command.
         *  @param x x coordinate of the rectangle position
         *  @param y y coordinate of the rectangle position.
         *  @param w Width of the rectangle (but see modifications possible with rectMode())
         *  @param h Height of the rectangle (but see modifications possible with rectMode())
         */
        public abstract void rect(float x, float y, float w, float h);
        
        /** Should draw an ellipse using the given location and dimensions. By default the x,y coordinates
         *  will be centre of the ellipse, but the meanings of these parameters should be able to be 
         *  changed with Processing's ellipseMode() command.
         *  @param x x coordinate of the ellipse's position
         *  @param y y coordinate of the ellipse's position.
         *  @param w Width of the ellipse (but see modifications possible with ellipseMode())
         *  @param h Height of the ellipse (but see modifications possible with ellipseMode())
         */
        public abstract void ellipse(float x, float y, float w, float h);
        
        /** Should draw a triangle through the three pairs of coordinates.
         *  @param x1 x coordinate of the first triangle vertex.
         *  @param y1 y coordinate of the first triangle vertex.
         *  @param x2 x coordinate of the second triangle vertex.
         *  @param y2 y coordinate of the second triangle vertex.
         *  @param x3 x coordinate of the third triangle vertex.
         *  @param y3 y coordinate of the third triangle vertex.
         */
        public abstract void triangle(float x1, float y1, float x2, float y2, float x3, float y3);
        
        /** Should draw a complex line that links the given coordinates. 
         *  @param xCoords x coordinates of the line.
         *  @param yCoords y coordinates of the line.
         */
        public abstract void polyLine(float[] xCoords, float[] yCoords);
        
        /** Should draw a closed polygon shape based on the given arrays of vertices.
         *  @param xCoords x coordinates of the shape.
         *  @param yCoords y coordinates of the shape.
         */
        public abstract void shape(float[] xCoords, float[] yCoords);
}


public abstract class AbstractChart
{
  
    static final float FLOAT_MAX_VALUE = 3.40282346638528860e+38;
    static final float FLOAT_MIN_VALUE = 1.40129846432481707e-45;
    final float NaN = 0.0f / 0.0f;
    // ----------------------------- Object variables ------------------------------

                        /** Parent sketch in which this chart is to be drawn.*/
    protected PApplet parent;
                                            /** Graphics context in which to send output. */
    protected PGraphics graphics;
                                            /** Alternative renderer for sketchy graphics and other styles. */
    protected Drawable renderer;
                        /** The datasets to be charted. */
    protected float[][] data;
                        /** Tic mark values for optional axis display. */
    protected float[][] tics,logTics;                     
                        /** Determines if the two primary axes should be transposed.*/
    protected boolean transposeAxesBool;              
                        /** For numerical formatting of axis labels. */
    /*protected DecimalFormat[] axisFormatter;*/
    protected int[] rightDigits; 
                                            /** Colour of axis lines. */
    protected int axisColour;
                                            /** Colour of the values shown on a chart axis. */
    protected int axisValuesColour;
                                            /** Colour of axis labels. */
    protected int axisLabelColour;        
                                            /** Determines if areal chart features are drawn with an edge or not. */
    protected boolean showEdge;
    
                        /** Indicates a int of the chart */
    protected class Side {
      public static final int TOP = 0;
      public static final int BOTTOM = 1;
      public static final int LEFT = 2;
      public static final int RIGHT = 3;
      public static final int NO_SIDE = 4;
    }
    
    protected boolean drawDecorations;                // If true, axes labels and title can be drawn; if false only data are drawn.
    
    
    private float minBorder;                            // Minimum internal border between bounds and chart.
    private float borderL,borderR,borderT,borderB;  // Actual internal borders between bounds and chart.
    private float minBorderL,minBorderR,minBorderT,minBorderB;
    
    private boolean[] isLogScale;                           // Indicates whether or not data are shown on log scale.
        
    private float[] min,max;                            // Minimum and maximum values for data on each axis.
    private float[] minLog,maxLog;
                                        
    private boolean[] forceMin,forceMax;        // Determines if minimum and maximum values are to be
                                                                                    // set explicitly (true) or by the data (false).
    
    private boolean[] showAxisArray;                         // Determines whether a chart axis is to be shown.
    private int[] axisPositions;                   // Position of axes.
   
    
    private static final int MAX_DIMENSIONS = 20; // Maximum number of dimensions represented by chart.
      
    // ------------------------------- Constructors --------------------------------

    /** Initialises the chart settings. Subclasses should normally call this constructor as a 
     *  convenience to initialise properties common to all charts.
     *  @param parent Sketch in which this chart is to appear.
     */
    protected AbstractChart(PApplet parent, PGraphics graphics)
    {
        this.parent = parent;
//        this.graphics = parent.g;
//        this.graphics = createGraphics(parent.width, parent.height);
        this.graphics = graphics;
        this.renderer = new RendererGraphics(graphics);
        
        data             = new float[MAX_DIMENSIONS][];
        tics             = new float[MAX_DIMENSIONS][];
        logTics          = new float[MAX_DIMENSIONS][];
        
        min              = new float[MAX_DIMENSIONS];
        max              = new float[MAX_DIMENSIONS];
        minLog           = new float[MAX_DIMENSIONS];
        maxLog           = new float[MAX_DIMENSIONS];
        isLogScale       = new boolean[MAX_DIMENSIONS];

        forceMin         = new boolean[MAX_DIMENSIONS];
        forceMax         = new boolean[MAX_DIMENSIONS];
        showAxisArray         = new boolean[MAX_DIMENSIONS];
        
        axisPositions    = new int[MAX_DIMENSIONS];
        rightDigits    = new int[MAX_DIMENSIONS];
        
        showEdge         = true;
        
        drawDecorations  = true;
        axisColour       = color(120);
        tickColour       = color(0, 0, 0, 51);
        /*axisColour       = color(0);*/
        /*axisLabelColour  = color(120);*/
        axisValuesColour = color(120);
        
        
        transposeAxesBool    = false;
        minBorder        = 3;
        borderL          = minBorder;
        borderR          = minBorder;
        borderT          = minBorder;
        borderB          = minBorder;
        minBorderL       = minBorder;
        minBorderR       = minBorder;
        minBorderT       = minBorder;
        minBorderB       = minBorder;
        
        for (int i=0; i<MAX_DIMENSIONS; i++)
        {
            forceMin[i]      = false;
            forceMax[i]      = false;
            showAxisArray[i]      = false;
            isLogScale[i]    = false;
            axisPositions[i] = Side.NO_SIDE;
            /*axisFormatter[i] = new DecimalFormat("###,###,###.######");    */
            rightDigits[i] = 0;
        }
    }
    
    // ---------------------------------- Methods ----------------------------------

    /** Should draw the chart within the given bounds. All implementing classes must include
     *  this method do do the drawing.
     *  @param xOrigin Side.LEFT-hand pixel coordinate of the area in which to draw the chart.
     *  @param yOrigin top pixel coordinate of the area in which to draw the chart.
     *  @param width Width in pixels of the area in which to draw the chart.
     *  @param height Height in pixels of the area in which to draw the chart.
     */
    protected abstract void draw(float xOrigin, float yOrigin, float width, float height);
    
        /** Sets the the graphics context into which all output is directed. This method allows
         *  output to be redirected to print output, offscreen buffers etc. Note that changing
         *  the graphics context in this way will also reset the renderer used to draw the graphics.
         *  @param graphics New graphics context in which the chart is embedded.
         */
        public void setGraphics(PGraphics graphics)
        {
                this.graphics = graphics;
                this.renderer = new RendererGraphics(graphics);
        }
        
        /** Sets the the renderer to be used for drawing graphics. This allows alternative renderers
         *  to be substituted for fine-grain control of graphical appearance. Note that if the graphics
         *  context is changed with <code>setGraphics()</code>, any custom renderers will be lost.
         *  @param renderer New renderer to be used for drawing graphics.
         */
        public void setRenderer(Drawable renderer)
        {
                this.renderer = renderer;
        }
        
        /** Determines whether decorations such as title, axes, and labels are drawn or not. This can
         *  be useful when two or more graphs with the same decorations are to be overlain. Only one
         *  of the graphs need draw the decorations.
         *  @param drawDecorations If true, axes, labels and titles can be drawn.
         */
        public void setDecorations(boolean drawDecorations)
        {
                this.drawDecorations = drawDecorations;
        }
        
        /** Determines the colour of the axis lines of the chart
         *  @param colour Colour of the axis lines of the chart.
         */
        public void setAxisColour(int colour)
        {
                this.axisColour = colour;
        }
        
        /** Determines the colour of the axis labels of the chart
         *  @param colour Colour of the axis labels of the chart.
         */
        public void setAxisLabelColour(int colour)
        {
                this.axisLabelColour = colour;
        }
        
        /** Determines the colour of the axis values of the chart
         *  @param colour Colour of the axis values of the chart.
         */
        public void setAxisValuesColour(int colour)
        {
                this.axisValuesColour = colour;
        }
        
        /** Determines whether or not to draw lines around and areal chart features. If true the current 
         *  stroke colour and weight will be used.
     *  @param showEdge Edges drawn if true.
     */
    public void setShowEdge(boolean showEdge)
    {
        this.showEdge = showEdge;
    }
  
    /** Sets the data to be displayed along the given axis of the chart. Updates the min and max ranges
     *  in response to the new data.
     *  @param dimension Dimension of the data to add.
     *  @param data Collection of data items to represent in the chart.
     */
    protected void setData(int dimension, float[] data)
    {
        if (dimension >= MAX_DIMENSIONS)
        {
            println("Warning: Cannot set data for dimension "+dimension+": permissable range 0-"+(MAX_DIMENSIONS-1));
            return;
        }
        
        // Avoid having empty data in chart.
        if (data == null)
            {
                    setData(dimension, new float[] {});
                    return;
            }
        
        this.data[dimension] = data;
        updateChart(dimension);
    }
    
    /** Reports the data to be displayed along the given axis of the chart. 
     *  @param dimension Dimension of the data to report.
     *  @return data Collection of data items represented in the chart or null if no data exist in the given dimension.
     */
    protected float[] getData(int dimension)
    {
        if (dimension >= MAX_DIMENSIONS)
        {
            println("Warning: Cannot get data for dimension "+dimension+": permissable range 0-"+(MAX_DIMENSIONS-1));
            return null;
        }
        return data[dimension];
    }
        
    /** Sets the minimum and maximum values of the data to be charted on the axis of the given dimension.
     *  If either the min or max values given are <code>Float.NaN</code>, then the minimum or maximum
     *  value respectively will be set to that of the min/max data items in the given dimension.
     *  @param dimension Dimension of the data whose minimum value is to be set.
     *  @param min Minimum value to be represented on the axis or <code>Float.NaN</code> for natural data minimum.
     *  @param max Maximum value to be represented on the axis or <code>Float.NaN</code> for natural data maximum..
     */
    
    public boolean isNaN(float f) {
        return f != f;
    }
    
    protected void setRange(int dimension, float min, float max)
    {
        if (isNaN(min))
        {
            forceMin[dimension] = false;
        }
        else
        {
            forceMin[dimension] = true;
            this.min[dimension] = min;
        }

        if (isNaN(max))
        {
            forceMax[dimension] = false;
        }
        else
        {
            forceMax[dimension] = true;
            this.max[dimension] = max;     
        }
        updateChart(dimension);
    }
    
    /** Sets the minimum value of the data to be charted on the axis of the given dimension.
     *  If the given value is <code>Float.NaN</code>, then the minimum value will be set to 
     *  the minimum of the data items in the given dimension.
     *  @param dimension Dimension of the data whose minimum value is to be set.
     *  @param min Minimum value to be represented on the axis or <code>Float.NaN</code> if data
     *             minimum is to be used.
     */
    protected void setMin(int dimension, float min)
    {
        if (isNaN(min))
        {
            forceMin[dimension] = false;
        }
        else
        {
            forceMin[dimension] = true;
            this.min[dimension] = min;
        }
        updateChart(dimension);
    }
    
    /** Reports the minimum value of the data to be charted on the axis of the given dimension.
     *  @param dimension Dimension of the data whose minimum value is to be retrieved.
     *  @return Minimum value to be represented on the axis.
     */
    protected float getMin(int dimension)
    {
       return min[dimension];
    }
    
    /** Reports the maximum value of the data to be charted on the axis of the given dimension.
     *  @param dimension Dimension of the data whose maximum value is to be retrieved.
     *  @return Maximum value to be represented on the axis.
     */
    protected float getMax(int dimension)
    {
       return max[dimension];
    }
    
    /** Reports the minimum value of the log10 of the data to be charted on the axis of the given dimension.
     *  @param dimension Dimension of the data whose minimum value is to be retrieved.
     *  @return Minimum value to be represented on the axis assuming log scaling.
     */
    protected float getMinLog(int dimension)
    {
       return minLog[dimension];
    }
    
    /** Reports the maximum value of the log10 of the data to be charted on the axis of the given dimension.
     *  @param dimension Dimension of the data whose maximum value is to be retrieved.
     *  @return Maximum value to be represented on the axis assuming log scaling.
     */
    protected float getMaxLog(int dimension)
    {
       return maxLog[dimension];
    }
    
    /** Sets the maximum value of the data to be charted on the axis of the given dimension.
     *  If the given value is <code>Float.NaN</code>, then the maximum value will be set to 
     *  the maximum of the data items in the given dimension.
     *  @param dimension Dimension of the data whose maximum value is to be set.
     *  @param max Maximum value to be represented on the axis or <code>Float.NaN</code> if data
     *             minimum is to be used.
     */
    protected void setMax(int dimension, float max)
    {
        if (isNaN(max))
        {
            forceMax[dimension] = false;
        }
        else
        {
            forceMax[dimension] = true;
            this.max[dimension] = max;
        }
       updateChart(dimension);
    }
    
    /** Sets the minimum internal border between the edge of the graph and the drawing area.
     *  @param border Minimum internal border size in pixel units.
     */
    protected void setMinBorder(float border)
    {
        minBorder = border;
    }
    
    /** Sets the minimum internal border between the given edge of the chart and the drawing area.
     *  If the given value is less than that given to the no-arguments method <code>setMinBorder()</code>,
     *  then this method has no effect.
     *  @param border Border at the given int in pixel units.
     *  @param int int of the chart to set the minimum border size.
     */
    protected void setMinBorder(float border, int side)
    {
        switch (side)
        {
            case Side.TOP:
                minBorderT = Math.max(minBorder,border);
                break;
            case Side.BOTTOM:
                minBorderB = Math.max(minBorder,border);
                break;
            case Side.LEFT:
                minBorderL = Math.max(minBorder,border);
                break;
            case Side.RIGHT:
                minBorderR = Math.max(minBorder,border);
                break;
            default:
                // Do nothing.
        }
    }
    
    /** Sets the internal border between the given edge of the chart and the drawing area.
     *  This method is used for explicit setting of border dimensions and will also reset
     *  the minimum border to the given dimension.
     *  @param border Border at the given int in pixel units.
     *  @param int int of the chart to set the border size.
     */
    protected void setBorder(float border, int side)
    {
        switch (side)
        {
            case Side.TOP:
                borderT = border;
                minBorderT = border;
                break;
            case Side.BOTTOM:
                borderB = border;
                minBorderB = border;
                break;
            case Side.LEFT:
                borderL = border;
                minBorderL = border;
                break;
            case Side.RIGHT:
                borderR = border;
                minBorderR = border;
                break;
            default:
                // Do nothing.
        }
    }
     
    /** Reports the minimum internal border between the chart and the drawing area.
     *  @return Minimum border between chart and drawing area in pixel units.
     */
    protected float getMinBorder()
    {
        return minBorder;
    }
    
    /** Reports the internal border between the given edge of the chart and the drawing area.
     *  This value is at least <code>getMinBorder()</code> and large enough to accommodate any axis labelling.
     *  @param int int of the chart to query.
     *  @return Border at the given int in pixel units.
     */
    protected float getBorder(int side)
    {
        switch (side)
        {
            case TOP:
                return Math.max(minBorderT,borderT);
            case BOTTOM:
                return Math.max(minBorderB,borderB);
            case Side.LEFT:
                return Math.max(minBorderL,borderL);
            case RIGHT:
                return Math.max(minBorderR,borderR);
            default:
                return 0;
        }
    }
    
    /** Determines whether or not the axis representing the given dimension is drawn.
     *  @param dimension Dimension of the data to have axis displayed or hidden.
     *  @param isVisible Axis is drawn if true.
     *  @param int int of chart along which axis is drawn.
     */
    protected void showAxis(int dimension, boolean isVisible, int side)
    {
        if (this.showAxisArray[dimension] != isVisible)
        {
                if (data[dimension] == null)
                {
                        setData(dimension, new float[]{});
                }
                
            this.showAxisArray[dimension] = isVisible;
            if (isVisible)
            {
                axisPositions[dimension] = side;
            }
            else
            {
                axisPositions[dimension] = Side.NO_SIDE;
            }

            if (side == Side.TOP)
            {
                borderT    = minBorder;
                minBorderT = minBorder;
                if (isVisible)
                {
                    //  Update the border to accommodate labels assuming horizontal text.
                    borderT = Math.max(borderT,graphics.textAscent()+graphics.textDescent());
                }
            }
            else if (side == Side.BOTTOM)
            {
                borderB    = minBorder;
                minBorderB = minBorder;
                if (isVisible)
                {
                    //  Update the border to accommodate labels assuming horizontal text.
                    borderB = Math.max(borderB,graphics.textAscent()+graphics.textDescent());
                }
            }
            else if (side == Side.LEFT)
            {
                borderL    = minBorder;
                minBorderL = minBorder;
                if ((isVisible) && (tics != null))
                {
                    //  Update the border to accommodate largest label assuming horizontal text.
                    for (float tic : tics[dimension])
                    {
                        borderL = Math.max(borderL, graphics.textWidth(nfc(tic, rightDigits[dimension])));
                    }
                }
            }
            else if (side == Side.RIGHT)
            {
                borderR    = minBorder;
                minBorderR = minBorder;
                if ((isVisible) && (tics != null))
                {
                    //  Update the border to accommodate largest label assuming horizontal text.
                    for (float tic : tics[dimension])
                    {
                        borderR = Math.max(borderR, graphics.textWidth(nfc(tic, rightDigits[dimension])));
                    }
                }
            }
           
            // Rounding of axis values may increase range.
            updateChart(dimension);
        }
    }
    
    /** Reports whether or not the axis representing the given dimension is drawn.
     *  @param dimension Dimension of the data to query.
     *  @return True if given axis dimension is drawn.
     */
    protected boolean getShowAxis(int dimension)
    {
        if (dimension >= MAX_DIMENSIONS)
        {
            return false;
        }
        return showAxisArray[dimension];
    }
    
    /** Reports whether or not the data in the given dimension are to be represented on the log10 scale.
     *  @param dimension Dimension of the data to query.
     *  @return True if the data in the given dimension are to be log-scaled.
     */
    protected boolean getIsLogScale(int dimension)
    {
        if (dimension >= MAX_DIMENSIONS)
        {
            return false;
        }
        return isLogScale[dimension];
    }
    
    /** Determines whether or not the data in the given dimension are to be represented on the log10 scale.
     *  @param dimension Dimension of the data to set.
     *  @param isLog True if the data in the given dimension are to be log-scaled or false if linear.
     */
    protected void setIsLogScale(int dimension, boolean isLog)
    {
        if (dimension >= MAX_DIMENSIONS)
        {
            return;
        }
        isLogScale[dimension] = isLog;
    }
    
    /** Sets the numerical format for numbers shown on the axis of the given dimension.
     *  @param dimension Dimension of the data axis to format.
     *  @param format Format for numbers on the given data axis.
     */
    protected void setFormat(int dimension, int digits)
    {
        rightDigits[dimension] = digits;
        
        if (showAxisArray[dimension])
        {
            // Only Side.LEFT or right borders can be affected by changes in label format (assuming horizontal text).
            if (axisPositions[dimension] == Side.LEFT)
            {
               
                borderL = minBorderL;
                for (float tic : tics[dimension])
                {
                    borderL = Math.max(borderL, graphics.textWidth(nfc(tic, rightDigits[dimension])));
                }
            }
            else if (axisPositions[dimension] == Side.RIGHT)
            {
                borderR = minBorderR;
                for (float tic : tics[dimension])
                {
                    borderR = Math.max(borderR, graphics.textWidth(nfc(tic, rightDigits[dimension])));
                }
            }
        }
    }
    
    /** Converts the given value, which is assumed to be positive, to a log value
     *  scaled between 0 and 1
     *  @param dataItem Item from which to find log value.
     *  @param minLogValue Minimum value of the log10 of dataItem (used to scale result between 0-1)
     *  @param maxLogValue Maximum value of the log10 of dataItem (used to scale result between 0-1)
     *  @return Log-scaled equivalent of the given value.
     */
    public float log10 (double x) {
      return (log((float)x) / log(10));
    }
    
    protected float convertToLog(double dataItem, double minLogValue, double maxLogValue)
    {
        if (dataItem <= 0)
        {
            return 0;
        }
        return (float)((log10(dataItem)-minLogValue)/(maxLogValue-minLogValue));
    }
    
    /** Converts the given value assumed to be on a log scale between 0 and 1, to an non-log value. 
     *  @param logValue 0-1 log value from which the data value is to be found. If this value is
     *                  outint the 0-1 range, a value of 0 will be returned.
     *  @param minLogValue Minimum value of the log10 of dataItem (used to unscale the logValue from 0-1)
     *  @param maxLogValue Maximum value of the log10 of dataItem (used to unscale the logValue from 0-1)
     *  @return Data value that would have produced the given scaled log value within the given range.
     */
    protected float convertFromLog(double logValue, double minLogValue, double maxLogValue)
    {
        if ((logValue < 0) || (logValue >1))
        {
            return 0;
        }
        
        double unscaledLog = logValue*(maxLogValue-minLogValue) + minLogValue;
        return (float)Math.pow(10,unscaledLog);
    }
   
    // ------------------------------ Private methods ------------------------------

    /** Updates the scaling and labelling of the chart depending on the values to be represented. 
     *  This method should be called whenever the range of data to be represented have changed.
     *  @param dimension Index referring to the data dimension to update.
     */
    private void updateChart(int dimension)
    {
            if (data[dimension] == null)
            {
                    data[dimension] = new float[]{};
            }
            
            if (data[dimension].length == 0)
            {
                    if (min[dimension] == max[dimension])
                    {
                            min[dimension] = Math.min(0,min[dimension]);
                            max[dimension] = Math.max(1,max[dimension]);
                    }
                    tics[dimension] = getTics(min[dimension], max[dimension]);
            }
            
        // Update the range of values of dataset if it exists.
        if ((data[dimension] != null) && (data[dimension].length > 0))
        {                                   
            if (forceMin[dimension] == false)
            {
                min[dimension]    = FLOAT_MAX_VALUE;  
                minLog[dimension] = FLOAT_MAX_VALUE;
                
                for (float dataItem : data[dimension])
                {
                    min[dimension] = Math.min(min[dimension], dataItem);
                }
            }
            else
            {
                minLog[dimension] = (float)log10(Math.max(Math.min(0.001,max[dimension]/1000.0), min[dimension]));  
                //println("Min x forced to be "+min[dimension]+" with min log at "+minLog[dimension]);
            }

            if (forceMax[dimension] == false)
            {
                max[dimension]    = -FLOAT_MAX_VALUE;
                maxLog[dimension] = -FLOAT_MAX_VALUE;
                
                for (float dataItem : data[dimension])
                {
                    max[dimension] = Math.max(max[dimension], dataItem);
                }
            }
            else
            {
                maxLog[dimension] = (float)log10(max[dimension]);
            }

            

            tics[dimension] = getTics(min[dimension], max[dimension]);
            
            //println("** Min log:"+minLog[dimension]);    
            logTics[dimension] = getLogTics(Math.pow(10,minLog[dimension]), max[dimension]);

            if (showAxisArray[dimension])
            {
                for (float tic : tics[dimension])
                {
                    if (forceMax[dimension] == false)
                    {
                        max[dimension] = Math.max(max[dimension], tic);
                    }
                    if (forceMin[dimension] == false)
                    {
                        min[dimension] = Math.min(min[dimension], tic);
                    }
                }
                
                for (float tic : logTics[dimension])
                {
                    if (forceMax[dimension] == false)
                    {
                        maxLog[dimension] = Math.max(maxLog[dimension], tic);
                    }
                    if (forceMin[dimension] == false)
                    {
                        minLog[dimension] = Math.min(minLog[dimension], tic);
                    }
                }
            }
        }
    }

    /** Provides an array of tic marks at rounded intervals between the given minimum and maximum values.
     *  @param minValue Minimum value to be represented within the tic marks.
     *  @param maxValue Maximum value to be represented within the tic marks.
     *  @return Array of tic mark positions.
     */
    private float[] getTics(double minValue, double maxValue)
    {
            double minVal = Math.min(minValue,maxValue);
            double maxVal = Math.max(minValue,maxValue);
            
            if (minVal == maxVal)
            {
                    minVal -= 0.5;
                    maxVal += 0.5;
            }
            
        float spacing = findSpacing(minVal, maxVal);
        float minTic = (float)Math.floor(minVal/spacing)*spacing;
        float tic = minTic;
        int numTics = 0;
        
        while (tic < maxVal)
        {
            tic = minTic + numTics*spacing;
            numTics++;
        }
 
        float[] tics = new float[numTics];
        for (int i=0; i<numTics; i++)
        {
            tics[i] = minTic + i*spacing;
        }
        return tics;
    }
    
    /** Provides an array of tic marks at rounded intervals on a log scale between the given minimum and maximum values.
     *  @param minVal Minimum value to be represented within the tic marks.
     *  @param maxVal Maximum value to be represented within the tic marks.
     *  @return Array of tic mark positions.
     */
    private float[] getLogTics(double minVal, double maxVal)
    {
        
        // Find decade of smallest value
        int minDecade = (int)Math.round(log10(minVal)-0.5);
        int maxDecade = (int)Math.round(log10(maxVal)+0.5);
        double maxLog = log10(maxVal);
        float[] mult;
        
        int range = maxDecade-minDecade;
        if (range < 3)
        {
            mult = new float[] {1, 2, 5};
        }
        else if (range < 5)
        {
            mult = new float[] {1, 5};
        }
        else
        {
            mult = new float[] {1};
        }
         
        //println("Min decade: "+Math.pow(10,minDecade)+ " max decade: "+Math.pow(10, maxDecade)+" range from "+minVal+" to "+maxVal);
        //int numTics = (range+1)*mult.length;
        
        
        ArrayList<Double> tics = new ArrayList<Double>();
        
        for (int i=0; i<=range; i++)
        {
            for (int m=0; m<mult.length; m++)
            {
                double tic = log10(Math.pow(10.0,minDecade+i) * mult[m]);
                if (tic <= maxLog)
                {
                    tics.add(new Double(tic));
                }
            }
        }
        
        float[] ticArray = new float[tics.size()];
        for (int i=0; i<ticArray.length; i++)
        {
            ticArray[i] = tics.get(i).floatValue();
        }
        return ticArray;

        
        

        /*
        println("Min decade: "+Math.pow(10,minDecade)+" max decade: "+Math.pow(10,maxDecade));
        
        float spacing = findSpacing(minVal, maxVal);
        //float minTic = Math.round(minVal/spacing)*spacing;
        float minTic = (float)minVal;
        
        float tic = minTic;
        int numTics = 0;

        while (tic < maxVal)
        {
            tic = minTic + numTics*spacing;
            numTics++;
        }
        float maxTic = minTic + (numTics-1)*spacing;
 
        if (minTic <=0)
        {
            minTic = (float)(maxTic/Math.pow(10,numTics));
        }
 
        return getTics(log10(minTic), log10(maxTic));
        */
    }

    /** Finds a suitable spacing between the given minimum and maximum values. Used for positioning
     *  tic marks for axis labels.
     *  @param minVal Minimum value to be represented along a chart axis.
     *  @param maxVal Maximum value to be represented along a chart axis.
     *  @return Suitable space between rounded values.
     */
    private float findSpacing(double minVal, double maxVal)
    {
        double r = maxVal-minVal;
        double newMaxVal = maxVal;
        if (r <= 0)
        {
            newMaxVal = minVal+1;
        }

        int n = (int)Math.floor(log10(r));
        int minInterval =  4;
        int maxInterval = 7;
        double[] mu = new double[] {0.1,0.2,0.5,1,2,5};

        int i=0;
        while (i <mu.length)
        {
            int interval = (int) Math.round(r/(mu[i]*Math.pow(10, n)))+1;
            if ((interval >= minInterval) && (interval <=maxInterval))
            {
                return (float)(mu[i]*Math.pow(10,n));
            }
            i++;
        }
        // Shouldn't get to this line.
        return (float)(newMaxVal-minVal);
    }
    
    /** Drawable version of the PGraphics class. Used as a default renderer.
     */
    private class RendererGraphics implements Drawable
    {
            private PGraphics gr;
            
            public RendererGraphics(PGraphics graphics)
            {
                    this.gr = graphics;
            }
            
                public void point(float x, float y)
                {
                        gr.point(x,y);
                }

                public void line(float x1, float y1, float x2, float y2) 
                {
                        gr.line(x1,y1,x2,y2);
                }

                public void rect(float x, float y, float w, float h) 
                {
                        gr.rect(x,y,w,h);
                }
                
                public void ellipse(float x, float y, float w, float h) 
                {
                        gr.ellipse(x,y,w,h);
                }

                public void triangle(float x1, float y1, float x2, float y2, float x3,float y3) 
                {
                        gr.triangle(x1,y1,x2,y2,x3,y3);
                }
                
                public void shape(float[] xCoords, float[] yCoords)
                {
                        gr.beginShape();
                        for (int i=0; i<xCoords.length; i++)
                        {
                                gr.vertex(xCoords[i],yCoords[i]);
                        }
                        gr.endShape(PConstants.CLOSE);
                }
                
                public void polyLine(float[] xCoords, float[] yCoords)
                {
                        gr.pushStyle();
                        gr.noFill();
                        gr.beginShape();
                        for (int i=0; i<xCoords.length; i++)
                        {
                                gr.vertex(xCoords[i],yCoords[i]);
                        }
                        gr.endShape();
                        gr.popStyle();
                }
    }
}

public class Double {
    public double value;
    
    public Double(double value) {
        this.value = value;
    }
    
    public float floatValue() {
        return (float)this.value;
    }
}

