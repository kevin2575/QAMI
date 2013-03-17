
function [handles]=loadDcmImages(hObject,handles)
%todo:1. get the lumin,contrast,curSeries,curSlice,flagGoodQual,allRoi
%todo:2. set the min max property of sldWinWidth and sldWinCenter,respectively
%todo:3. process the oriImg according to the window width and window
%        center.if the image needs segment and the state of tglBtnSegShow is on
%        ,call ostu to get the threshold,select the object and set it to 
%        max value,then show it.
%todo:4. if the image was marked goodqual,draw the yellow box around it.
%        if the image has ori, draw ori box,update the ckbGoodQual
%        control,then display the histogram of the ori

curSeries = handles.uidata.curSeries;
curSlice = handles.uidata.curSlice;
curIndex = doubleInd2singleInd(curSlice,curSeries,handles);
curSegSlice = handles.uidata.curSegSlice;
% luminosity = handles.uidata.luminosity;
% contrasts = handles.uidata.contrast;
flagGoodQual = handles.uidata.flagGoodQual(curSeries,curSlice);
curRoi = floor(handles.uidata.allRoi(curIndex,:));
curSliceRoi = floor(handles.uidata.curSliceRoi);

oriImg = double(dicomread(handles.uidata.dcmInfo{curIndex}));
maxx=max(max(oriImg));
minn=min(min(oriImg));
set(handles.sldWinCenter,'max',maxx); 
set(handles.sldWinCenter,'min',minn); 
set(handles.sldWinWidth,'max',maxx-minn); 
set(handles.sldWinWidth,'min',0);         
tmpW =  get(handles.sldWinWidth,'Value');
tmpC = get(handles.sldWinCenter,'Value');
if (tmpC > maxx)
    set(handles.sldWinCenter,'value',maxx); 
else if (tmpC< minn)
        set(handles.sldWinCenter,'value',minn); 
    end
end
if (tmpW > (maxx-minn))
    set(handles.sldWinWidth,'value',maxx-minn); 
end

imgToShow = visualProcess(oriImg,handles);
tglBtnSegShowState = get(handles.tglBtnSegShow,'Value');
if curSlice == curSegSlice && tglBtnSegShowState == 1
    thresholdValue = ostu(imgToShow);
    roiRegion = imgToShow(curSliceRoi(2):curSliceRoi(1),curSliceRoi(3):curSliceRoi(4));
    roiRegion(roiRegion > thresholdValue) = 256;
    imgToShow(curSliceRoi(2):curSliceRoi(1),curSliceRoi(3):curSliceRoi(4)) = roiRegion;
    imgToShow(:,:,1) = imgToShow(:,:,1);
    imgToShow(:,:,2) = imgToShow(:,:,1);
    imgToShow(:,:,3) = imgToShow(:,:,1);
    imgToShow(curSliceRoi(2):curSliceRoi(1),curSliceRoi(3):curSliceRoi(4),2) = 0;
    imgToShow(curSliceRoi(2):curSliceRoi(1),curSliceRoi(3):curSliceRoi(4),3) = 0;
end
imshow(imgToShow,'parent',handles.axesImg);

% pos = get(handles.axesImg,'position');
tpos(1) = 256; tpos(2) = 1; tpos(3) = 1; tpos(4) = 256;
tglDrawState = get(handles.tglBtnDrawRoi,'Value');
if flagGoodQual == 1 && handles.uidata.isDrawingRoi == 0
    drawBoxes(handles.axesImg,tpos,[1 1 0]);
end
if sum(curRoi)>0 && handles.uidata.isDrawingRoi == 0
    drawBoxes(handles.axesImg,curRoi,[0 1 0]);
    if curRoi(1) >= 0 && curRoi(2) > 0 && curRoi(3) > 0 && curRoi(4) > 0 && abs(curRoi(1) - curRoi(2))>0....
        && abs(curRoi(3) - curRoi(4)) > 0
        axes(handles.axesStat);
        roiRegion = uint16(oriImg(curRoi(2):curRoi(1),curRoi(3):curRoi(4)));
        maxValue = max(max(roiRegion));
        minValue = min(min(roiRegion));
        [counts x] = imhist(roiRegion,65536);
        imhist(roiRegion,65536);
        set(gca,'xlim',[minValue maxValue],'ylim' ,[0 max(counts)]);
    else
        axes(handles.axesStat);
        plot([1 1],[0 0]);
    end
end
set(handles.ckbGoodQual,'Value',flagGoodQual);

set(handles.edtDispNumTime,'String',num2str(handles.uidata.curSeries));
set(handles.lbFileList,'Value',doubleInd2singleInd(handles.uidata.curSlice,handles.uidata.curSeries,handles));
set(handles.tglBtnDrawRoi,'Value',0);

set(handles.sldSeries,'value',curSeries);
minValue = get(handles.sldSlice,'min');
maxValue = get(handles.sldSlice,'max');
set(handles.sldSlice,'value',minValue + maxValue - curSlice);

guidata(hObject,handles);

