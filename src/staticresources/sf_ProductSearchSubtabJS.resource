var jsTimer = null;
var lastSearch = '';

//refresh the primary tab
function refreshSelectedCaseTab(){
	//orikkers
	sforce.console.getSubtabIds(sfPrimaryTabId, function(result){ 
		sforce.console.refreshSubtabById(result.ids[0], false, function (){
		}); //assuming first one is always details
	});
}

function refreshProductsAddedTab(){
	var refreshSuccess = function refreshSuccess(result) {
		//Report whether refreshing the subtab was successful
		if (result.success == true) {
			console.log('Products Added refreshed successfully');
		} else {
			console.log('Products Added Subtab did not refresh');
		}
	};
}

var productSearchAutocomplete = function ($this, $country) {
	$('.noResults').hide();
	$('.divider-horizontal').show();

	var searchType = $('input[name=productSearchType]:checked').val();

	$($this).autocomplete({
		minLength: 3,
		delay: 400,
		source: function (request, response) {
			var startTime = new Date().getTime();
			lastSearch = request.term;
			sf_ProductSearchSubtabController.doSoslSearch (request.term, $country, searchType, function(result, event){
				if(event.status) {
					$('#searchResults').empty();
					$('#searchPathResults table').empty();

					response (result);
					$('.ui-autocomplete').hide();
					var searchTime = new Date().getTime() - startTime;

					if(result.length > 0){
						//build list of ids
						var prodIds = [];
						for (i = 0; i < result.length; i++) { 
							prodIds.push(result[i].product.Id);
						}
						//WR544 Concurrent User-UI product search redesign 

						/*console.log('calling getDamImageThumbnailUrlInBulk');
						getDamImageThumbnailUrlInBulk (prodIds);*/

						$('.resultsSection').show();
						$('.noResults').hide();
						$('#radioResultsType').show();
						$('.displayedResults').show();

						var resultsType = $('input[name=productResultsType]:checked').val();
						if(resultsType == 'productResults'){
							$('.divider-horizontal').show();
							$('#searchPathResults').hide();
							$('#searchResults').show();
						} else {
							$('.divider-horizontal').hide();
							$('#searchPathResults').show();
							$('#searchResults').hide();
						}
					} else {
						$('.resultsSection').hide();
						$('.noResults').show();
						$('#radioResultsType').hide();
						$('displayedResults').hide();
						$('.divider-horizontal').hide();
					}
					
					$('.processingTime').text('  ' + result.length + ' results (' + searchTime + 'ms)'); // Cas: removed time component
					//$('.processingTime').text('  ' + result.length + ' results'); 
					$('.processingTime').css('color','green');
				} else {
					$('#searchResults').empty();
					$('#searchPathResults table').empty();

					$('.resultsSection').hide();
					$('.noResults').show();

					$('.processingTime').text('ERROR - ' + event.message);
					$('.processingTime').css('color','red');
				}
			});
		},
		
		select: function (event, ui) {
			
			sf_ProductSearchSubtabController.addProduct (ui.item.Id, caseId, function(result, event){
				if(event.status) {
					refreshCaseProducts();
					refreshSelectedCaseTab();
					refreshProductsAddedTab();
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
				var resultsType = $('input[name=productResultsType]:checked').val();

				if(resultsType == 'productResults'){
					//WR544 Only display for product results if the product has a gtin
					if(typeof item.product.GTIN_Number__c != 'undefined' && item.product.GTIN_Number__c != ''){
						return displayProductResults(item);
					}
				} 
				return displayProductPaths(item);

			};
		}// end create
	}).focus(function() { // onfocus redo search
		//$(this).autocomplete("search");//ChrisM May 2017 removed as causing search to keep running on switching tabs
	});

}; // end productSearchAutocomplete

function displayProductResults(item){

	var gtin = '';
	var rawGTIN = '';
	if(typeof item.GTIN != 'undefined' && item.GTIN != ''){
		gtin = 'GTIN: ' + item.GTIN;
		rawGTIN = item.GTIN;
	}

	var ipms = '';
	var rawIPMS = '';
	if(typeof item.IPMS != 'undefined' && item.IPMS != ''){
		ipms = 'IPMS: ' + item.IPMS;
		rawIPMS = item.IPMS;
	}

	var productBrand = '';
	if(typeof item.product.Consumer_Facing_Brand__c != 'undefined' && item.product.Consumer_Facing_Brand__c != ''){
		productBrand = item.product.Consumer_Facing_Brand__c;
	}

	var name = getLocalProductName(item.product.Consumer_Facing_Name__c, item.product.Translated_Path__c);
	var addButton = '<img class="addProductButton" style="cursor:pointer;" src="' + addButtonDefault + '"';
	addButton += ' onMouseOver="this.src=\'' + addButtonHover + '\'"';
	addButton += ' onMouseOut="this.src=\'' + addButtonDefault + '\'"';
	addButton += ' onMouseDown="this.src=\'' + addButtonPress + '\'"';
	addButton += ' onMouseUp="this.src=\'' + addButtonDefault + '\'"';
	addButton += ' onclick="addProduct(\'' + item.product.Id + '\', \'' + productBrand + '\',\'' + rawGTIN + '\', \'' + rawIPMS + '\'); return false;"></img>';

	var count = getLocalProductCount(item.product.Id);
	var addNotify = '';
	if(count > 0){
		addNotify = '<div id="addId' + item.product.Id + '" class="addedProductText">' + count + ' ' + addedText + '</div>';
	} else {
		addNotify = '<div id="addId' + item.product.Id + '" class="productAddText">' + addText + '</div>'; //chris large add text
	}

	var description = '';
	if(typeof item.product.Product_Description__c != 'undefined' && item.product.Production_Description__c != ''){
		description = item.product.Product_Description__c + '<br/>';
	} else {
		description = noDescription;
	}
    
	var rowData = '';
	rowData += '<table>';
	rowData += '<tr>';
	rowData += '<td class=\"productInfoColumn\"><p class="productNameText">' + name + '</p><p class="productWeightUpcText">' + gtin  + '</p></td>'; //Product Title

	if(typeof item.product.Image_Url_Thumb__c != 'undefined' && item.product.Image_Url_Thumb__c != ''){
        rowData += '<td class=\"addButtonContainer\" rowspan="2"> <img style="cursor:pointer; height:36px" src="'+openImage+'" onclick="openProductPopup(\'' + item.product.Id + '\');ga(\'send\', \'event\', \'Event_Form_Interaction\', \'Event_Button_Click\', \'Console Product Image Display Click\');"></img></td>';
	}

	rowData += '<td class=\"addButtonContainer\" rowspan="2">' + addButton + addNotify + '</td>';
	rowData += '</tr>';
	rowData += '<tr>';
	rowData += '<td class="productPath" colspan="2">' + getProductPath(item) + '</td>';
	rowData += '</tr>';
	rowData += '</table>'; 

	return $('#searchResults').append(rowData);
}

function getProductPath(item){
	var path = '';
	var pathSplit = item.product.Translated_Path__c.split('/');
	if(pathSplit.length > 0){
		path = pathSplit[0];
	
		for(var i = 1; i < pathSplit.length; i++) {
			path = path + '<div class="dividerLine"></div>' + pathSplit[i];
		}
	}
	return path;
}

function displayProductPaths(item){
	var productBrand = '';
	if(typeof item.product.Consumer_Facing_Brand__c != 'undefined' && item.product.Consumer_Facing_Brand__c != ''){
		productBrand = item.product.Consumer_Facing_Brand__c;
	}

	var gtin = '';
	var rawGTIN = '';
	if(typeof item.GTIN != 'undefined' && item.GTIN != ''){
		gtin = 'GTIN: ' + item.GTIN;
		rawGTIN = item.GTIN;
	}

	var ipms = '';
	var rawIPMS = '';
	if(typeof item.IPMS != 'undefined' && item.IPMS != ''){
		ipms = 'IPMS: ' + item.IPMS;
		rawIPMS = item.IPMS;
	}

	var addButton = '<img class="addSmallProductButton" style="cursor:pointer;" src="' + addSmallButtonDefault + '"';
	addButton += ' onMouseOver="this.src=\'' + addSmallButtonHover + '\'"';
	addButton += ' onMouseOut="this.src=\'' + addSmallButtonDefault + '\'"';
	addButton += ' onMouseDown="this.src=\'' + addSmallButtonPress + '\'"';
	addButton += ' onMouseUp="this.src=\'' + addSmallButtonDefault + '\'"';
	addButton += ' onclick="addProduct(\'' + item.product.Id + '\', \'' + productBrand + '\',\'' + rawGTIN + '\', \'' + rawIPMS + '\'); return false;"></img>';

	var count = getLocalProductCount(item.product.Id);
	var addNotify = '';
	if(count > 0){
		addNotify = '<div id="addId' + item.product.Id + '" class="addedProductText">' + count + ' ' + addedText + '</div>'; //Chris 2
	} else {
		addNotify = '<div id="addId' + item.product.Id + '" class="productAddText">' + addText + '</div>'; //Chris small add text
	}

	var rowData = '';
	rowData += '<tr>'
	rowData += '<td class=\"pathColumn\" style="border-right:0px;">' + getProductPath(item) + '</td>';
	if(typeof item.product.Image_Url_Thumb__c != 'undefined' && item.product.Image_Url_Thumb__c != ''){
		rowData += '<td style="width: 40px; border-left: 1px solid; border-right: 1px solid; border-top:1px solid; border-color: rgb(236,236,236)"> <img style="cursor:pointer;" src="'+openImage+'" onclick="openProductPopup(\'' + item.product.Id + '\');ga(\'send\', \'event\', \'Event_Form_Interaction\', \'Event_Button_Click\', \'Console Product Path Image Display Click\');"></img> </td>';
	}
	else{
		rowData += '<td style="width: 0px; border-right: 1px solid; border-top:1px solid; border-color: rgb(236,236,236)"></td>';	
	}
	rowData += '<td class=\"addSmallButtonColumn\" >' + addButton + addNotify + '</td>';
	rowData += '</tr>'

	return $('#searchPathResults table').append(rowData);
}

function getLocalProductName(inName, inPath){
	var name = '';
	var lineAndSize = '';
	var split = inPath.split('/');
	if(typeof inName == 'undefined' || inName == ''){
		name = split[0];
		if(split.length > 1){
			name += ', ' + split[1];
		}
		if(split.length > 2){
			name += ', ' + split[2];
		}

	} else {
		name = inName;
	}

	return name + lineAndSize;
}

function getLocalProductCount(lpId){
	if(localProductMap[lpId] === undefined){
		return 0;
	} else {
		return localProductMap[lpId];
	}
}
function removeLocalProductCount(lpId){
	if(localProductMap[lpId] === undefined){
		return 0;
	} else {
		localProductMap[lpId] = localProductMap[lpId] - 1;
		return 0;
	}
}

function addProduct($prodId, lpBrand, gtin, ipms){
	sf_ProductSearchSubtabController.addProduct($prodId, lpBrand, caseId, lastSearch, gtin, ipms, function(result, event){
		if(event.status) {
			localProductMap[$prodId] = result;//update map that holds the current count for each Local Product.
			$('* #addId' + $prodId).text(result + ' ' + addedText);
			$('* #addId' + $prodId).removeClass('productAddText').addClass('addedProductText');
			refreshSelectedCaseTab();
			refreshProductsAddedTab();
			showRefreshNotificationOnProductCommentTab();
		} else {
			$('.processingTime').text('ERROR - ' + event.message);
			$('.processingTime').css('color','red');
		}
	});
}

function hideSearchPanel(){
	$('.caseNotSelected').show();
	$('.productSearchPanel').hide();
	console.log('Search Panel Hidden');
}

function showSearchPanel(){
	$('.caseNotSelected').hide();
	$('.productSearchPanel').show();

	$('#radioSearchType').buttonset(); //button set for Bar Code/Free Text
	//After changing the search type, attempt to search again
	$("#radioSearchType").change(function(event) {
		$('.productSearchBar').focus();

		//toggle image for free text when option changes
		var searchType = $('input[name=productSearchType]:checked').val();
		if(searchType == 'freeText'){
			$('.tabButtonFreeTextImage').attr('src', freeTextActiveImage);
		} else {
			$('.tabButtonFreeTextImage').attr('src', freeTextDefaultImage);
		}

		$("#radioResultsType").hide();
		$('.noResults').hide();
		$('.resultsSection').hide();
	});

	$('#radioResultsType').buttonset(); //button set for Product Results/Path Results
	
	//After changing the search type, attempt to search again
	$("#radioResultsType").change(function(event) {
		$('.productSearchBar').focus();
	});
}