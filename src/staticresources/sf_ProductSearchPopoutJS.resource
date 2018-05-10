var caseId = '';
//var caseLanguage = '';
var sfPrimaryTabId = null;
var jsTimer = null;

/** 
* This function disables the product search when a tab is closed. 
* onFocusedPrimaryTab then determines if the Product Search should be enabled.
*/
var onEnclosingPrimaryTabClose = function (result) {
    getPrimaryTabId();
};
sforce.console.addEventListener(sforce.console.ConsoleEvent.CLOSE_TAB, onEnclosingPrimaryTabClose);

//Grab tab id and case record id
var previousOnload = window.onload; window.onload = function() { 
    console.log("previousOnload function entered");
    
    if (previousOnload) { 
        previousOnload(); 
    }
    getPrimaryTabId();

} 

function getPrimaryTabId(){
    //Get the primary tab id to be used for refreshes
    var getTabId = function (result) {
        sfPrimaryTabId = result.id;
    };
    sforce.console.getFocusedPrimaryTabId(getTabId);
    
    //Get the object ID of the current tab
    var getObjectId = function (result){
        //console.log('OnLoad ObjectId: Object Id: ', result.id);
        
        var recordId = result.id;
        if(recordId != 'null'){
            sf_PopOutProductSearchConsoleCompCtrl.checkObjectId(recordId, function(result, event){
                if(event.status) {
                    if (result == 'Case'){
                        caseId = recordId;
                        setCaseId(caseId);
                        //getCaseLanguage(caseId);
                        showSearchPanel();
                    }else{
                        hideSearchPanel();
                        console.log(event.message);
                    }
                }
            });
        } else {          
            hideSearchPanel();
        }
    };
    sforce.console.getFocusedPrimaryTabObjectId(getObjectId);
}

//Retrieve case language for filtering case comment code results.
/*function getCaseLanguage(){
    caseLanguage = '';
    if(caseId != '' && caseId != null){
        sf_PopOutProductSearchConsoleCompCtrl.getCaseLanguage(caseId, function(result, event){
            if(event.status) {
                caseLanguage = result;
                //console.log('***Language Set to: ' + caseLanguage);
            } else {
                alert (event); 
            }
        });
    }
}*/

//refresh the primary tab
function refreshSelectedCaseTab(){
    var refreshSuccess = function (result) {
        if (result.success) {
            console.log('Primary tab refreshed successfully');
        } else {
            console.log('Primary did not refresh');
        }
    };
    sforce.console.refreshPrimaryTabById(sfPrimaryTabId, true, refreshSuccess);
}

// get primary tab selected and record id if exists
var onFocusedPrimaryTab = function (result) {
    console.log("onFocusedPrimaryTab function entered");
    
    
    if (result.objectId != "null"){
        var primaryTabId = result.id;
        var recordId = result.objectId;
        
        // verify that the current tab is a case record
        sf_PopOutProductSearchConsoleCompCtrl.checkObjectId(result.objectId, function(result, event){
            if(event.status) {
                if (result == 'Case'){
                    caseId = recordId;
                    sfPrimaryTabId = primaryTabId;
                    setCaseId(caseId); 
                    //getCaseLanguage(caseId);
                    showSearchPanel();
                } else {
                    hideSearchPanel();
                }
            } else {
                $('.processingTime').text('ERROR - ' + event.message);
                $('.processingTime').css('color','red');
            }
        });
        // end verify
    } else {
        hideSearchPanel();
    }
};
sforce.console.onFocusedPrimaryTab(onFocusedPrimaryTab);
// end get primary

var productSearchAutocomplete = function ($this, $country) {
    var gtinCheckboxValue = $('.gtinCheckbox').prop('checked');

    $($this).autocomplete({
        minLength: 3,
        delay: 400,
        source: function (request, response) {
            
            var startTime = new Date().getTime();
            sf_PopOutProductSearchConsoleCompCtrl.doSoslSearch (request.term, $country, gtinCheckboxValue, function(result, event){
                if(event.status) {
                    response (result);
                    
                    var searchTime = new Date().getTime() - startTime;
                    
                    $('.processingTime').text('  ' + result.length + ' results (' + searchTime + 'ms)'); // Cas: removed time component
                    //$('.processingTime').text('  ' + result.length + ' results'); 
                    $('.processingTime').css('color','green');
                } else {
                    
                    $('.processingTime').text('ERROR - ' + event.message);
                    $('.processingTime').css('color','red');
                }
            });
        },
        
        select: function (event, ui) {
            
            sf_PopOutProductSearchConsoleCompCtrl.addProduct (ui.item.Id, caseId, function(result, event){
                if(event.status) {
                    refreshCaseProducts();
                    refreshSelectedCaseTab();
                } else {
                    
                    $('.processingTime').text('ERROR - ' + event.message);
                    $('.processingTime').css('color','red');
                }
            });
            $(this).blur(); // unfocus search box after selecting a product.
            return false;
        }, //end select
        
        close : function (event, ui) {
            return false;  
        }, //end close
        
        create: function () {
            $(this).data('ui-autocomplete')._renderItem = function (ul, item) {
                return $('<li>')
                .append('<a>' + item.Translated_Path__c + '</a>')
                .appendTo(ul);
            };
        }// end create
    }).focus(function() { // onfocus redo search
        $(this).autocomplete("search");
    });
    
}; // end productSearchAutocomplete

//case comment search methods
var caseCommentSearchAutocomplete = function ($element, $country, $productId, $globalProductId, $caseLanguage, $brand, $segment){
    var levelOneFilter = $('.level1SearchFilter' + $productId + ' option:selected').val();
    var levelTwoFilter = $('.level2SearchFilter' + $productId + ' option:selected').val();
    console.log('***LevelOneFilter: ' + levelOneFilter);
    console.log('***LevelTwoFilter: ' + levelTwoFilter);

    //console.log('***CaseLanguage(var): ' + caseLanguage);
    console.log('***CaseLanguage(rec): ' + $caseLanguage);
    var codeTimeTag = '.' + $productId + 'codeProcessingTime';
    $($element).autocomplete({
        minLength: 3,
        delay: 400,
        source: function (request, response) {
            var startTime = new Date().getTime();
            sf_PopOutProductSearchConsoleCompCtrl.doCaseCommentSoslSearch ($globalProductId, $brand, $segment, request.term, $country, $caseLanguage, levelOneFilter, levelTwoFilter, function(result, event){
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
            sf_PopOutProductSearchConsoleCompCtrl.addCaseCommentCode(caseId, ui.item.Id, $productId, function(result, event){
                console.log (event);
                console.log (result);
                if(event.status){
                    refreshCaseComments();
                    refreshSelectedCaseTab();
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
                if (!item.Description__c) item.Description__c = item.Full_Translated_Path__c;
                //console.log('***Criticality__c ' + item.Criticality__c);
                var style = '';
                if(item.Criticality__c == 'Critical'){
                    style = 'background-color:#FF4D4D;';
                }

                return $('<li>')
                .append('<a style="' + style + '" title="' + item.Description__c + '">' + item.Full_Translated_Path__c + '</a>')                
                .appendTo(ul);
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
    if(jsTimer == null){
        jsTimer = setInterval(function(){getPrimaryTabId(); console.log("TimerHit");},3000);
    }
    $('.ui-autocomplete').hide();
    $('.caseNotSelected').show();
    $('.productSearchPanel').hide();
    $('.commentCodeDictionary').hide();
    console.log('Search Panel Hidden');
}

function showSearchPanel(){
    if(jsTimer != null){
        clearInterval(jsTimer);
        jsTimer = null;     
    }
    $('.ui-autocomplete').hide();
    $('.caseNotSelected').hide();
    $('.productSearchPanel').show();
    $('.commentCodeDictionary').hide();
    console.log('Search Panel Displayed');
}

function showCommentCodeDictionary(){
    $('.ui-autocomplete').hide();
    $('.caseNotSelected').hide();
    $('.productSearchPanel').hide();
    $('.commentCodeDictionary').show();
    console.log('Comment Code Dictionary Displayed');
}

function navigateToSurveySummary() {
    try {
        var url = 'apex/sf_CaseSurveyProbingQuestions?Id='+caseId;
        console.log('Survey URL: ' + url);
        sforce.console.openSubtab(sfPrimaryTabId, url, true, 'Survey Questions', null, null, 'Survey Tab Name');
    } catch (err) {
        console.log (err);
    }
}
