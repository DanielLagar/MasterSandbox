if (!window.console) {console={log: function () {}}; }

var $j = jQuery.noConflict();
var sfPrimaryTabId = null;

sforce.console.getEnclosingPrimaryTabId (function (result) {
    sfPrimaryTabId = result.id;
});

//refresh the primary subtab
function refreshSelectedCaseTab(){
    //orikkers
    sforce.console.getSubtabIds(sfPrimaryTabId, function(result){ 
        console.log('getSubtabIds ', result);
        sforce.console.refreshSubtabById(result.ids[0], false, function (){
            console.log ('refreshSubtabById', result);
        }); //assuming first one is always details
    });
}

function lookupPrimaryZipCode(ev){
    if(ev.which === 13){
        $j('.lookupPrimary').focus();
        $j('.lookupPrimary').trigger("click");
        ev.preventDefault();
    }
    
}


function lookupOtherZipCode(ev){
    if(ev.which === 13){
        $j('.lookupOther').focus();
        $j('.lookupOther').trigger("click");
        ev.preventDefault();
    }
}

function scrollToTop(){
    //document.querySelector("[id$='apexMessagesId']").scrollIntoView();
}

function setUnverifiedPrimaryAddress(element){
    $j(element).removeClass("invalidField");
    $j(element).removeClass("validField");
    $j(element).removeClass("verifiedField");
    var parentElement = $j(element).parent();
    $j(parentElement).find("img").removeClass("validIcon");
    $j(parentElement).find("img").addClass("hideAddressIcon");
    
    $j(parentElement).find(".invalidFieldText").addClass("hideAddressIcon");
    $j(parentElement).find(".invalidFieldText").removeClass("invalidFieldText");

}

$j(document).ready(function() {
    $j(".phoneField").mask("?999999999999999", {placeholder:""});
    preventEnterPress();
});

function preventEnterPress(){
    $j('input').bind('keypress', function(e){
        if(e.keyCode == 13){
            return false;
        }
    });
}

function refreshChecklist(){
    console.log('fired checklist refresh event');
    sforce.console.fireEvent('sf_RefreshChecklistEvent', '{!currentCase}');
}

var reloadSubtabs = function() {
    sforce.console.getFocusedPrimaryTabId(function (result) {
      if(result.success) {
          sforce.console.fireEvent('sf_ReloadSubtabsEvent', result.id);
      }
    });
}


var reloadSingleSubtab = function(){
    sforce.console.getFocusedSubtabId(function (result) {
        if(result.success) {
            sforce.console.fireEvent('sf_ReloadSingleSubtab', result.id);
      }
    });
}