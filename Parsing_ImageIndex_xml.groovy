import ij.*
import ij.gui.*
import ij.io.*
import ij.macro.*
import ij.measure.*
import ij.plugin.*
import ij.plugin.filter.*
import ij.plugin.frame.*
import ij.process.*
import ij.text.*
import ij.util.*

import org.scijava.util.XML;


dir = IJ.getDirectory("Choose a Directory");
File xmlFile = new File(dir + "ImageIndex.xml");

xml = new XML(xmlFile)
ImageIndex = xml.elements("//ImageIndex/MeasurementRecord")

sb = new StringBuilder("path, Time, Column, Row, Timepoint, FieldIndex, ZIndex, Ch, X, Y, Ignore\n");
for (MeasurementRecord in ImageIndex) {
	path = XML.cdata(MeasurementRecord)
	Time = MeasurementRecord.getAttribute("bts:Time")
	Column = MeasurementRecord.getAttribute("bts:Column")
	Row = MeasurementRecord.getAttribute("bts:Row")
	TimePoint = MeasurementRecord.getAttribute("bts:TimePoint")
	FieldIndex = MeasurementRecord.getAttribute("bts:FieldIndex")
	ZIndex = MeasurementRecord.getAttribute("bts:ZIndex")
	Ch = MeasurementRecord.getAttribute("bts:Ch")
	X = MeasurementRecord.getAttribute("bts:X")
	Y = MeasurementRecord.getAttribute("bts:Y")

	
	sb.append(path)
	sb.append("," + Time)
	sb.append("," + Column)
	sb.append("," + Row)
	sb.append("," + TimePoint)
	sb.append("," + FieldIndex)
	sb.append("," + ZIndex)
	sb.append("," + Ch)
	sb.append("," + X)
	sb.append("," + Y + "\n")
	
}

new File(dir + "ImageIndex.csv").text = sb.toString();

//String ImageStack = new File("Create_Imagestack_from_CV1000_10(with_stitch)_.ijm");
//IJ.runMacroFile(ImageStack, dir)


