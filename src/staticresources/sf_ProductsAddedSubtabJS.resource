var jsTimer = null;

//refresh the primary tab
function refreshSelectedCaseTab(){
    retrieveImages();
    //orikkers
    sforce.console.getSubtabIds(sfPrimaryTabId, function(result){ 
        sforce.console.refreshSubtabById(result.ids[0], false, function (){
        }); //assuming first one is always details
    });
}

//Grab tab id and case record id
var previousOnload = window.onload; window.onload = function() {     
    if (previousOnload) { 
        previousOnload(); 
    }  
} 

//case comment search methods
var caseCommentSearchAutocomplete = function ($element, $country, $productId, $globalProductId, $caseLanguage, $brand, $segment){
    var levelOneFilter = $('.level1SearchFilter' + $productId + ' option:selected').val();
    var levelTwoFilter = $('.level2SearchFilter' + $productId + ' option:selected').val();
    var codeTimeTag = '.' + $productId + 'codeProcessingTime';

    //$($element).autocomplete("option", "position", { my : "right top", at: "right bottom" } );
    $($element).autocomplete({
        minLength: 3,
        delay: 400,
        source: function (request, response) {
            var startTime = new Date().getTime();
            sf_ProductsAddedSubtabController.doCaseCommentSoslSearch ($globalProductId, $brand, $segment, request.term, $country, $caseLanguage, levelOneFilter, levelTwoFilter, function(result, event){
                if(event.status) {
                    response (result);
                    var searchTime = new Date().getTime() - startTime;
                    $(codeTimeTag).text('  ' + result.length + ' results (' + searchTime + 'ms)');
                    $(codeTimeTag).css('color','green');
                } else {
                    $(codeTimeTag).text('ERROR - ' + event.message);
                    $(codeTimeTag).css('color','red');
                }
            });
        },                
        
        select: function (event, ui) {
            sf_ProductsAddedSubtabController.addCaseCommentCode(caseId, ui.item.Id, $productId, function(result, event){
                if(event.status){
                    $('.lastAddedCCCId').attr('value', event.result.cccId);
                    if (result.mstId != null) {
                        openProductAssociationPopup ($productId, event.result.mstId, true);
                    } else {
                        updateCaseCommentList($productId);
                    }
                }else{
                    $(codeTimeTag).text('ERROR - ' + event.message);
                    $(codeTimeTag).css('color','red');
                }
            });
            $(this).blur(); // unfocus search box after selecting a case comment code.
            return false;
        }, //end select
        
        close : function (event, ui) {
            return false;  
        }, //end close
        
        create: function () {
            $(this).data('ui-autocomplete')._renderItem = function (ul, item) {
                if(!item.Description__c) item.Description__c = item.Full_Translated_Path__c;
                //console.log('***Criticality__c ' + item.Criticality__c);

                var level2Style = '';
                //font-size:11px;font-family:\"Arial\";color:rgb(0,0,0);line-height:1.182;';
                var level3Style = '';
                //font-size:12px;font-family:\"Arial\";font-weight:bold;color:rgb(0,0,0);line-height:1.182;';

                var critImage = '';
                if(item.Criticality__c == 'Critical'){
                    critImage = '<img src="' + criticalityImageUrl + '" class="autocompleteCriticalityImage"/> ';
                }

                if(item.Global_Comment_Code__r.Reason_Required__c){
                    var rowData = '';
                    rowData += '<a title="' + item.Description__c + '">';
                        rowData += '<div style="position: relative;">' + critImage + '</div>';
                        rowData +='<div style="margin-left: 30px;">';
                            rowData += '<div class="commentLevel3Text">' + item.Level_3__c + '</div>';
                        rowData += '</div>';
                    rowData += '</a>';
                    //return $('ul').append(rowData);

                    return $("<li></li>").data("ui-autocomplete-item", item)
                    .append(rowData).appendTo(ul);
                } else {
                    var rowData = '';
                    rowData += '<a title="' + item.Description__c + '">';
                        rowData += '<div style="position: relative;">' + critImage + '</div>';
                        rowData +='<div style="margin-left: 30px;">';
                            rowData += '<div class="commentLevel2Text" style="padding-bottom: 5px;">' + item.Level_2__c + '<br/></div>';
                            rowData += '<div class="commentLevel3Text">' + item.Level_3__c + '</div>';
                        rowData += '</div>';
                    rowData += '</a>';
                    //return $('ul').append(rowData);

                    return $("<li></li>").data("ui-autocomplete-item", item)
                    .append(rowData).appendTo(ul);
                }
            };
            
            $( document ).tooltip({
                track: true
            });
        }// end create
    }).focus(function() { // onfocus redo search
        $(this).autocomplete("search");
    });
}; // end caseCommentSearchAutocomplete


function hideSearchPanel(){
    /*if(jsTimer == null){
        jsTimer = setInterval(function(){getPrimaryTabId(); console.log("TimerHit");},3000);
    }*/
    $('.ui-autocomplete').hide();
    $('.caseNotSelected').show();
    $('.productSearchPanel').hide();
    console.log('Search Panel Hidden');
}

function showSearchPanel(){
    /*if(jsTimer != null){
        clearInterval(jsTimer);
        jsTimer = null;     
    }*/
    $('.ui-autocomplete').hide();
    $('.caseNotSelected').hide();
    $('.productSearchPanel').show();
    retrieveImages();
    console.log('Search Panel Displayed');
}