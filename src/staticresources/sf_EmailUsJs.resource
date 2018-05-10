/*
EmailUs page JS
*/


var submitForm = function () {
    
    isFormValid = $('[id$=contactUsForm]').validate().valid();
    console.log ('submitForm isFormValid', isFormValid);

    if (isFormValid)  
        submitEmailUsForm();
    
        
    return isFormValid;
};

var toggleSubmitButton = function (el) {
    if ($(el).prop('checked')) $('[id$=submitButton]').removeAttr('disabled');
    else $('[id$=submitButton]').attr('disabled', 'disabled');
};

function toggleProducts() {
	$("#product-rows").toggleClass("hidden");
}

function showBarcodeSearch(){
	$('#productTab').removeClass("active");
	$('#barcodeTab').addClass("active");
	$('#barcodeSearch').show();
	$('#productSearch').hide();
}

function showProductSearch(){
	$('#productTab').addClass("active");
	$('#barcodeTab').removeClass("active");
	$('#barcodeSearch').hide();
	$('#productSearch').show();
}

var countChar = function (el) {
    $('.overcharLimit').remove();
    var len = $(el).val().length;
    if (len > 4000) {
      $(el).val($(el).val().substring(0, 4000));
      var errorMessage = $('<span class="error overcharLimit">' + summaryExceededMessage + '</span>');
      $(el).after(errorMessage);
    } else {
      $('.overcharLimit').remove();
    }
};

var productSearchAutocomplete = function ($this, $brand, $country) {

    $($this).autocomplete({
        minLength: 3,
        delay: 400,
        search: function(event, ui) { 
            $('.progressSpinner').show();
        },
        source: function (request, response) {
            $('#searchResults').empty();
            $('.resultsFound').hide();
            var startTime = new Date().getTime();
            sf_EmailUsExt.doSoslProductSearch (request.term, $brand, $country, disableFilter, function(result, event){
                console.log ('Starting search', request);

                //capture search term
                $('[id$=productSearchTermText]').val(request.term);
                if(event.status) {
                    response (result);
                    console.log ('productSearchAutocomplete result ', result);
                    $('.ui-autocomplete').hide();

                    var searchTime = new Date().getTime() - startTime;
                    console.log ('found ' + result.length + ' in ' + searchTime);

                    if (result.length>0) {
                        $('.resultsFound').show();

                        //build list of ids
                        var prodIds = [];
                        for (i = 0; i < result.length; i++) { 
                            prodIds.push(result[i].Id);
                            //console.log (' for (i in result)', result[i]);
                        }
                        console.log('calling getDamImageThumbnailUrlInBulk');
                        getDamImageThumbnailUrlInBulk (prodIds);
                    }
                    
                    //$('.resultsFound').text('  ' + result.length + ' results found in (' + searchTime + 'ms)'); // Cas: removed time component
                    //$('.processingTime').text('  ' + result.length + ' results'); 
                    //$('.resultsFound').css('color','green');
                } else {
                    $('.resultsFound').text('ERROR - ' + event.message);
                    $('.resultsFound').css('color','red');
                }

                $('.progressSpinner').hide();
            });
        },
        
        select: function (event, ui) {
            return false;
        }, //end select
        
        close : function (event, ui) {
            return false;  
        }, //end close
        
        create: function () {
            $(this).data('ui-autocomplete')._renderItem = function (ul, item) {
                return displayProductResults(item);
            };
        }// end create
    }).focus(function() { // onfocus redo search
        //$(this).autocomplete("search");
    });
    
}; // end productSearchAutocomplete



var displayProductResults = function (item){
    //Assemble tags
    // var imageURL = '';
    // if(typeof item.Image_Url_Thumb__c != 'undefined' && item.Image_Url_Thumb__c != ''){
    //     imageURL = item.Image_Url_Thumb__c;
    // } else {
    //     imageURL = defaultImage;
    // }

    var imageURL = imageLoadingGif;

    var image = '<img width="' + imageWidth + '" height="'+ imageHeight +'" src="' + imageURL + '" class="productThumbnail" id="'+ item.Id +'"/> ';
    var name = item.Consumer_Facing_Name__c;
    var addButton = '<div class="addProductButton fa fa-plus-circle fa-2x '+ item.Id +'"';
    addButton += ' onclick="addProduct(\'' + item.Id + '\', \'\');"></div>';
    var cpCount = $('.selectedProductResults').find('.'+item.Id).length;
    var cpCountText = addText;
    if (cpCount>0) {
        cpCountText = cpCount + ' ' + addedLabel;
    }
    var addButtonTextId = 'addId' + item.Id;
    var addNotify = '<div class="productAddText ' + addButtonTextId + '">' + cpCountText + '</div>';

    var description = '';
    if(typeof item.Product_Description__c != 'undefined' && item.Production_Description__c != ''){
        description = item.Product_Description__c + '<br/>';
    } else {
        description = noDescription;
    }

    // var gtin = '';
    // if(typeof item.GTIN_Number__c != 'undefined' && item.GTIN_Number__c != ''){
    //     gtin = item.GTIN_Number__c;
    // }

    var rowData = '';
    rowData += '<table>';
    rowData += '<tr>';
    rowData += '<td class=\"imageColumn\" style="width:'+ imageWidth +'px;\">' + image + '</td>';
    rowData += '<td class=\"productInfoColumn\"><p class="productNameText">' + name + '</p></td>'; //<p class="productWeightUpcText">' + gtin + '</p>
    rowData += '<td class=\"productDetailsColumn\"><p class="productDescriptionText">' + description + '</p></td>';
    rowData += '<td class=\"addButtonContainer\">' + addButton + addNotify + '</td>';
    rowData += '</tr>';
    rowData += '<tr>';
    //rowData += '<td class="productPath" colspan="3">' + getProductPath(item) + '</td>';
    rowData += '</tr>';
    rowData += '</table>';

    return $('#searchResults').append(rowData);
};

var localProductId = '';

var addProduct = function (productId, gtin) {
    console.log ('addProduct', productId);
    addCaseProduct (productId, gtin);
    localProductId = productId;
};

var clearSearchResults = function () {
    $('#searchResults').empty();
    $('#gtinSearchResults').empty();
    $('.resultsFound').hide();
    $('.searchInput').val(''); //CDOY WR312 - Null the Search text after a product has been added to the case
    
};

var assignDeletedId = function (el) {
    localProductId = $(el).attr('prodId');
    console.log(localProductId);


    return true;
};

var countCaseProducts = function () {
    console.log ('counting Case Products', localProductId);
    var cpCount = $('.selectedProductResults').find('.'+localProductId).length;

    if (cpCount > 0) {
        $('.addId' + localProductId).html (cpCount + ' ' + addedLabel);
    } else {
        $('.addId' + localProductId).html (addText);
    }
};

var processAddedProductsUrls = function () {
    var lpIds = [];
    $('.selectedProductResults').find('.productThumbnail').each(function (){
        $(this).attr('src', imageLoadingGif);
        var lpId = $(this).attr('lpId');
        lpIds.push(lpId);
        console.log (lpIds);
    });

    processAddedProducts (lpIds);
}

var gtinSearchAutocomplete = function ($this, $brand, $country) {

    $($this).autocomplete({
        minLength: 3,
        delay: 400,
        search: function(event, ui) { 
            $('.progressSpinner').show();
        },
        source: function (request, response) {
            $('#gtinSearchResults').empty();
            $('.gtinResultsFound').hide();
            var startTime = new Date().getTime();

            //capture search term
            $('[id$=productSearchTermText]').val(request.term);

            // var term      = request.term.toLowerCase(),
            // element       = this.element,
            // cache         = this.element.data('autocompleteCache') || {},
            // foundInCache  = false;

            // $.each(cache, function(key, data){
            //   if (term.indexOf(key) === 0 && data.length > 0) {
            //     response(data);
            //     foundInCache = true;
            //     return;
            //   }
            // });

            // if (foundInCache) return;

            sf_EmailUsExt.doSoqlGTINSearch (request.term, $brand, $country, disableFilter, function(result, event){
                console.log ('Starting gtinSearchAutocomplete search', request);
                if(event.status) {
                    response (result);
                    console.log ('gtinSearchAutocomplete result ', result);
                    $('.ui-autocomplete').hide();

                    if (result.length > 0) $('.gtinResultsFound').show();

                    var searchTime = new Date().getTime() - startTime;
                    console.log ('found ' + result.length + ' in ' + searchTime);

                } else {
                    $('.gtinResultsFound').text('ERROR - ' + event.message);
                    $('.gtinResultsFound').css('color','red');
                }

                $('.progressSpinner').hide();
            });
        },
        
        select: function (event, ui) {
            return false;
        }, //end select
        
        close : function (event, ui) {
            return false;  
        }, //end close
        
        create: function () {
            $(this).data('ui-autocomplete')._renderItem = function (ul, item) {
                return displayGTINResults(item);
            };
        }// end create
    }).focus(function() { // onfocus redo search
        //$(this).autocomplete("search");
    });
    
}; // end gtinSearchAutocomplete


var displayGTINResults = function (item){
    //Assemble tags
    var imageURL = '';
    if(typeof item.Local_Product__r.Image_Url_Thumb__c != 'undefined' && item.Local_Product__r.Image_Url_Thumb__c != ''){
        imageURL = item.Local_Product__r.Image_Url_Thumb__c;
    } else {
        imageURL = defaultImage;
    }

    var gtin = '';
    if(typeof item.Name != 'undefined' && item.Name != ''){
        gtin = item.Name;
    }

    var image = '<img width="' + imageWidth + '" height="'+ imageHeight +'" src="' + imageURL + '" class="productThumbnail"/> '
    var name = item.Local_Product__r.Consumer_Facing_Name__c;
    var addButton = '<div class="addProductButton fa fa-plus-circle fa-2x"';
    addButton += ' onclick="addProduct(\'' + item.Local_Product__c + '\', \'' + gtin + '\');"></div>';

    var cpCount = $('.selectedProductResults').find('.'+item.Local_Product__c).length;
    var cpCountText = addText;
    if (cpCount>0) {
        cpCountText = cpCount + ' ' + addedLabel;
    }

    var addButtonTextId = 'addId' + item.Local_Product__c;
    var addNotify = '<div class="productAddText ' + addButtonTextId + '">' + cpCountText + '</div>';

    var description = '';
    if(typeof item.Local_Product__r.Product_Description__c != 'undefined' && item.Local_Product__r.Production_Description__c != ''){
        description = item.Local_Product__r.Product_Description__c + '<br/>';
    } else {
        description = noDescription;
    }

    var rowData = '';
    rowData += '<table>';
    rowData += '<tr>';
    rowData += '<td class=\"imageColumn\" style="width:'+ imageWidth +'px;\">' + image + '</td>';
    rowData += '<td class=\"productInfoColumn\"><p class="productNameText">' + name + '</p> <p class="productWeightUpcText">' + gtin + '</p> </td>';
    rowData += '<td class=\"productDetailsColumn\"><p class="productDescriptionText">' + description + '</p></td>';
    rowData += '<td class=\"addButtonContainer\">' + addButton + addNotify + '</td>';
    rowData += '</tr>';
    rowData += '<tr>';
    //rowData += '<td class="productPath" colspan="3">' + getProductPath(item) + '</td>';
    rowData += '</tr>';
    rowData += '</table>';

    return $('#gtinSearchResults').append(rowData);
};


/* ATTACHMENTS */


var maxStringSize = 6000000;    //Maximum String size is 6,000,000 characters
    var maxFileSize = 4350000;      //After Base64 Encoding, this is the max file size
    var chunkSize = 950000;         //Maximum Javascript Remoting message size is 1,000,000 characters
    var attachment;
    var attachmentName;
    var fileSize;
    var attachmentType;
    var positionIndex;
    var doneUploading;
    var displayedErrors=""; //Stores upload error messages
    
//Method to prepare a file to be attached to the Account bound to the page by the standardController
var uploadFile =  function () {
    $('#attachmentName').empty();
    $('#validationError').hide();
    $("#attachmentName").removeClass('error');
    var ext = $('#attachmentFile').val().split('.').pop().toLowerCase();
    var isAllowed = true;
    
    if($.inArray(ext, acceptExt.split(',')) == -1) {
        isAllowed = false;
    }

    var file = document.getElementById('attachmentFile').files[0];
    var binary = "";
    
    if(file != undefined && isAllowed) {
        if(file.size <= maxFileSize) {
            $('#attachmentFile').hide();
           
            $("#progressbar").progressbar({
                value: false
            });

            attachmentName = file.name;
            attachmentType = file.type;
            var fileReader = new FileReader();
            
            fileReader.onload = function(e) {
				var bytes = new Uint8Array(e.target.result);
				var length = bytes.byteLength;

				for (var i = 0; i < length; i++){
					binary += String.fromCharCode(bytes[i]);
				}		
            } //end onload
            
            
            fileReader.onloadend = function(e) {
                attachment = window.btoa(binary);  //Base 64 encode the file before sending it
                positionIndex=0;
                fileSize = attachment.length;
                
                console.log("Total Attachment Length: " + fileSize);
                
                doneUploading = false;
                if(fileSize < maxStringSize) {
                    uploadAttachment(null);
                } else {
                    $('#attachmentFile').show();
                    alert("Base 64 Encoded file is too large.  Maximum size is " + maxStringSize + " your file is " + fileSize + ".");
                }
             
            } //end onloadend
            
            fileReader.onerror = function(e) {
                alert("There was an error reading the file.  Please try again.");
            } //end onerror
            
            fileReader.onabort = function(e) {
                alert("There was an error reading the file.  Please try again.");
            } // end on abort
         
            fileReader.readAsArrayBuffer(file); //Supports IE 10 and up...
         
        } else {
            showAttError(fileIsTooBigMessage);
			displayedErrors += fileIsTooBigMessage+',';
            $("[id$='attachmentErrorMsgs']").val(displayedErrors);
        }

    } else {
        showAttError(invalidAttachmentExtMessage);
        displayedErrors += invalidAttachmentExtMessage+',';
       $("[id$='attachmentErrorMsgs']").val(displayedErrors);
    }
} //end uploadFile

var showAttError = function (msg) {
    //$('#attachmentFile').val(null); //Causes IE to rerun if loop and captures two error messages.
    $("#attachmentName").html(msg);
    $("#attachmentName").addClass('error');
    $('#validationError').show();
};
     
//Method to send a file to be attached to the Account bound to the page by the standardController
//Sends parameters: Account Id, Attachment (body), Attachment Name, and the Id of the Attachment if it exists to the controller   
var uploadAttachment = function (fileId) {
    var attachmentBody = "";
    if(fileSize <= positionIndex + chunkSize) {
        attachmentBody = attachment.substring(positionIndex);
        doneUploading = true;
    } else {
        attachmentBody = attachment.substring(positionIndex, positionIndex + chunkSize);
    }
    console.log("Uploading " + attachmentBody.length + " chars of " + fileSize);
    sf_EmailUsExt.doUploadAttachment(
        attachmentBody,
        attachmentName,
        attachmentType, 
        fileId,

        function(result, event) {
            console.log('doUploadAttachment result: ' + result);

            if(event.status) {
                if(result != null) {
                    if(doneUploading == true) {
                        console.log("file " + result + " has been succesfully uploaded.");
                        $("[id$='caseAttachmentId']").val(result);
                        $("#attachmentFile").remove();
                        $("#attachmentName").html(attachmentName);
                        $("#progressbar").progressbar('destroy');

                    } else {
                        positionIndex += chunkSize;
                        uploadAttachment(result);
                    }
                }
            } else { //something else happened in remote action
                console.log(event.message);
            }
        }, //end callback
        {buffer: true, escape: true, timeout: 120000}
    ); //end doUploadAttachment
} // end uploadAttachment var



//VALIDATION OF EMAIL, ADDRESS AND FORM

function setHasBeenVerified(value){
    $('#hasBeenVerified').val(value);
}
      
function openConfirmationDialog(userInputAddress, strikeIronSuggestion){

    var userInput = $('<div />').html(userInputAddress).text();
    var suggestion = $('<div />').html(strikeIronSuggestion).text();
    //$('#divAddressByUser').html($.parseHTML(unescape(userInputAddress)).text());
    //$('#divAddressByService').html($.parseHTML(unescape(strikeIronSuggestion)).text());

    $('#divAddressByUser').html(userInput);
    $('#divAddressByService').html(suggestion);
    
    $( "#addressconfirmation" ).dialog("open");
}

function onSuggestedAddressSelected(radioEl, country){
    $(radioEl).prop('checked', false);
    setPrimaryAddressWithSuggestedAddress(country);
    setHasBeenVerified('true');
    $("#addressconfirmation").dialog("close");
}

function onKeepCurrentAddressSelected(radioEl){
    $(radioEl).prop('checked', false);
    setHasBeenVerified('false');
    $("#addressconfirmation").dialog("close");
    directSubmitForm();
}

function setSuggestedAddressVariables(validatedAddress1, validatedAddress2, validatedAddress3, validatedCity, validatedState, validatedZip){
    $("[id$='serviceAddressLine1']").val(validatedAddress1);
    $("[id$='serviceAddressLine2']").val(validatedAddress2);
    $("[id$='serviceAddressLine3']").val(validatedAddress3);
    
    $("[id$='serviceAddressCity']").val(validatedCity);
    $("[id$='serviceAddressState']").val(validatedState);
    $("[id$='serviceAddressZip']").val(validatedZip);       
}

function setPrimaryAddressWithSuggestedAddress(country){
    var addressLine1 = $("[id$='serviceAddressLine1']").val();
    var addressLine2 = $("[id$='serviceAddressLine2']").val();
    var addressLine3 = $("[id$='serviceAddressLine3']").val();
    var addressCity = $("[id$='serviceAddressCity']").val();
    var addressState = $("[id$='serviceAddressState']").val();
    var addressZip = $("[id$='serviceAddressZip']").val();
    
     if (country == 'Argentina' || country == 'Germany') {
        $("[id$='addressline1_SecondDisplayOption']").val(addressLine1);
        $("[id$='addressline2_SecondDisplayOption']").val(addressLine2);
        
        $("[id$='citytown_SecondDisplayOption']").val(addressCity);
        $("[id$='stateprovincecounty_SecondDisplayOption']").val(addressState);
        $("[id$='zippostalcode_SecondDisplayOption']").val(addressZip);
    } else if (country == 'China') {
        $("[id$='addressline1_ThirdDisplayOption']").val(addressLine1);
        $("[id$='addressline2_ThirdDisplayOption']").val(addressLine2);
        
        $("[id$='citytown_ThirdDisplayOption']").val(addressCity);
        $("[id$='stateprovincecounty_ThirdDisplayOption']").val(addressState);
        $("[id$='zippostalcode_ThirdDisplayOption']").val(addressZip);
    } else if (country == 'Japan') {
        console.log('Country is Japan ');
        $("[id$='addressline1_FourthDisplayOption']").val(addressLine1);
        $("[id$='addressline2_FourthDisplayOption']").val(addressLine2);
        
        $("[id$='citytown_FourthDisplayOption']").val(addressCity);
        $("[id$='stateprovincecounty_FourthDisplayOption']").val(addressState);
        $("[id$='zippostalcode_FourthDisplayOption']").val(addressZip);
    } else {
        $("[id$='addressline1']").val(addressLine1);
        $("[id$='addressline2']").val(addressLine2);
        
        $("[id$='citytown']").val(addressCity);
        $("[id$='stateprovincecounty']").val(addressState);
        $("[id$='zippostalcode']").val(addressZip);    
    }
}

function directSubmitForm(){
    $('[id*=sf_ProgressStatus\\.start]').show();
    $('#validationError').hide();
    $("[id$='overrideaddress']").val('true');
    submitForm();
}


    



