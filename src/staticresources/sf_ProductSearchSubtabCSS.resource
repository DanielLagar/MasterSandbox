
.ui-autocomplete-loading {
    background-color: white;
    background-image: url('/img/loading.gif');
    background-image: url('/img/loading.gif'), -moz-linear-gradient(90deg, rgb(255,255,255) 73%, rgb(193, 193, 193) 100%) !important;
    background-image: url('/img/loading.gif'), -webkit-linear-gradient(90deg, rgb(255,255,255) 73%, rgb(193, 193, 193) 100%) !important;
    background-image: url('/img/loading.gif'), -ms-linear-gradient(90deg, rgb(255,255,255) 73%, rgb(193, 193, 193) 100%) important;
    background-position: 98% center;
    background-repeat: no-repeat;
}

/* Search Section CSS */

.searchSection{
    margin: 0 auto;
    margin-top: 12px;
    width: 480px;
}

.tabButtonBarCodeImage{
    position: absolute;
    top: 0px;
    left: 5px;
}

.tabButtonFreeTextImage{
    position: absolute;
    top: 4px;
    left: 5px;
}

.productSearchBar{
    top: -1px;
    border-width: 1px;
    border-color: rgb(198, 204, 206);
    border-style: solid;
    border-bottom-left-radius: 3px;
    border-bottom-right-radius: 3px;
    border-top: none;
    background-image: -webkit-linear-gradient(90deg, rgb(255,255,255) 73%, rgb(193, 193, 193) 100%);    
    background-image:    -moz-linear-gradient(90deg, rgb(255,255,255) 73%, rgb(193, 193, 193) 100%);    
    background-image:     -ms-linear-gradient(90deg, rgb(255,255,255) 73%, rgb(193, 193, 193) 100%);
    width: 450px;
    height: 32px;
    font-size: 14px;
    font-family: "Arial";
    color: rgb(51, 51, 51);
    font-weight: bold;
    ling-height: 0.857;
    padding: 5px;
}

/* prevent toggle buttons from having rounded corners */
.ui-corner-left, .ui-corner-right{
    border-radius: 0px; !important;
}

#radioSearchType .tabButton{
    width: 152px;
    height: 25px;
}

#radioResultsType .tabButton{
    width: 150px;
    height: 20px;
}

input:checked + label{
    border-width: 1px;
    border-color: rgb(22, 95, 171);
    border-style: solid;
    border-bottom: none;
    background-color: #1E72CA;
    background-image: -webkit-linear-gradient( 90deg, rgb(30,114,202) 0%, rgb(22,95,171) 100%);
    background-image:    -moz-linear-gradient( 90deg, rgb(30,114,202) 0%, rgb(22,95,171) 100%);
    background-image:     -ms-linear-gradient( 90deg, rgb(30,114,202) 0%, rgb(22,95,171) 100%);

    font-size: 11px;
    font-family: "Arial";
    color: rgb(255, 255, 255);
    font-weight: bold;
    text-align: center;
}

.tabButton{
    border-width: 1px;
    border-color: rgb(196, 196, 196);
    border-style: solid;
    border-bottom: none;
    background-image: -webkit-linear-gradient( 90deg, rgb(240,242,243) 0%, rgb(240,242,242) 100%);
    background-image:    -moz-linear-gradient( 90deg, rgb(240,242,243) 0%, rgb(240,242,242) 100%);
    background-image:     -ms-linear-gradient( 90deg, rgb(240,242,243) 0%, rgb(240,242,242) 100%);

    font-size: 11px;
    font-family: "Arial";
    color: rgb(0, 0, 0);
    font-weight: bold;
    text-align: center;
}

.countryField{
    float: right;
    margin-right: 17px;
    margin-top: 8px;
}

.country{
    margin-left: 5px;
}

.processingTime{
    float: left;
    margin-top: 10px;
}

/* Results Section CSS */
.resultsSection{
    margin-left: 8px;
}

.imageColumn{
    width: 1%;
    padding: 0px 10px 0px 9px; //Chris for V2/V3 - remove
    border-bottom: 1px solid;
    border-top-left-radius: 4px;
}

.productThumbnail{
    border-width: 1px;
    border-color: rgb(198,204,206);
    border-style: solid;
    background-color: rgb(255,255,255);
    width: 78px;
    height: 78px;
}

.productInfoColumn{
    vertical-align: text-top;
    width: 275px;
    //padding-top: 9px; //Chris for V2/V3 - remove
    padding-right: 10px;
	border-bottom: 1px solid;
    border-right: 1px solid;
    //padding-bottom: 10px; //Chris for V2/V3 - remove
}

.productDetailsColumn{
    vertical-align: text-top;
    //padding-top: 9px; //Chris for V2/V3 - remove
    padding-right: 10px;
    //padding-bottom: 10px; //Chris for V2/V3 - remove
    padding-left: 9px;
    border-bottom: 1px solid;
}

.addButtonContainer{
    //width: 74px;
    width: 1%;
    border-left: 1px solid;
    border-top-right-radius: 4px;
    border-bottom-right-radius: 4px;
}

.productPath{
    //padding-left: 9px; //Chris for V2/V3 - remove
    height: 30px;
    border-bottom-left-radius: 4px;
}

#searchResults table:hover{
    background-color: rgb(227, 243, 255);
}

#searchResults table:hover td{
    border-color: rgb(255,255,255);
}

#searchResults table{
    margin-top: 10px;
    border-collapse: separate;
    border-width: 1px;
    border-color: rgb(198,204,206);
    border-style: solid;
    border-radius: 4px;
    background-color: rgb(255,255,255);
    border-spacing: 0px;
    width: 98%;
    cellpadding: 0px;
}

#searchResults td, #searchPathResults td{
    border-color: rgb(236,236,236);
}

.productNameText{
    font-weight: bold;
    margin-top: 0px;
    font-size: 14px;
    font-family: "Arial";
    color: rgb(0, 0, 0);
}

.productWeightUpcText{
    font-size: 13px;
    font-family: "Arial";
    color: rgb(0, 0, 0);
}

.productDescriptionText{
    margin-top: 0px;
    font-size: 12px;
    font-family: "Arial";
    color: rgb(0, 0, 0);
    text-align: left;
}

.addProductButton{
	margin: 15px 5px 15px 5px; //Chris updated
    //margin-bottom: 20px;
}

.productAddText{
    font-size: 10px;
    font-family: "Arial";
    color: rgb(86, 86, 96);
    text-align: center;    
}

.addedProductText{
    font-weight: bold;
    font-size: 10px;
    font-family: "Arial";
    color: rgb(137, 180, 42);
    text-align: center;
}

#searchPathResults table{
    border-collapse: separate;
    border-width: 1px;
    border-color: rgb(198,204,206);
    border-style: solid;
    border-top-right-radius: 4px;
    border-bottom-right-radius: 4px;
    border-bottom-left-radius: 4px;
    background-color: rgb(255,255,255);
    border-spacing: 0px;
    width: 98%;
    cellpadding: 0px;
}

#searchPathResults table tr:first-child td{
    border-top: none;
}

#searchPathResults table tr:first-child td:first-child{
    border-top-left-radius: 4px;
}

#searchPathResults table tr:first-child td:last-child{
    border-top-right-radius: 4px;
}

#searchPathResults table tr:hover{
    background-color: rgb(227, 243, 255);
}

#searchPathResults table tr:hover td{
    border-color: rgb(255,255,255);
}

.pathColumn{
    margin-top: 0px;
    height: 48px;
    //padding-top: 11px;
    //padding-bottom: 11px;
    padding-left: 10px;
    border-width: 1px;
    border-color: rgb(198,204,206);
    border-top: 1px solid;
    border-right: 1px solid;
    border-bottom-left-radius: 4px;
    vertical-align: middle;
}

.addSmallButtonColumn{
    width: 43px;
    border-width: 1px;
    border-color: rgb(198,204,206);
    border-top: 1px solid;
    border-bottom-right-radius: 4px;
}

.addSmallProductButton{
    //margin-top: 10px;
    margin-left: 11px;
    margin-bottom: 10px;
}

.backToTop{
    display: block;
    position: relative;
    bottom: 5px;
}

.noResults{
    margin-left: 25px;
}

.divider-horizontal{
    height: 1px;
    width: 98%;
    margin-top: -2px;
    overflow: hidden;
    background-color: rgb(198, 204, 206);
    border-top: 2px solid #FFF;
}
