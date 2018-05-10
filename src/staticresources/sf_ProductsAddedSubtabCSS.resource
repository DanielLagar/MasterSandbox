/* Product association popup */

    .screen_overlay_show{
        
        position: fixed;
        top: 0%;
        left: 0%;
        width: 100%;
        height: 100%;
        background-color: rgba(255,255,255,0.8);
        z-index:1001;
    }
    .white_content_show {
        position: fixed;
        top: 5%;
        bottom: 5%;
        left: 16%;
        font-family: "Arial";
        background-color: white;
        z-index:5002;
        overflow: auto;
        width: 66%;
        box-shadow: 0px 20px 40px 0px rgba(0, 0, 0, 0.196);
    }

    .productDetail {
       
        margin-top: 22px;
        margin-bottom: 20px;
        font-size: 14px;
        line-height: 16.8px;
    }

    .productDetail img, 
    .productDetail label {
        display: block;
        font-weight: bold;
    }

    .productDetail span {
        font-weight: normal;
        display: inline;
    }

    .col-span3 {
        width: 70%;
    }

    .col-span1 {
        float: right;
        height: 60px;
        padding-top: 27px;
    }

    hr { 
        color: rgb(22, 95, 171);
    }

    .sasList {
        margin-left: 31px;
        margin-right: 30px;
        margin-top: 22px;
        margin-bottom: 30px;
    }

    .popupHeader {
        padding-top: 17px;
        padding-bottom: 19px;
        padding-left: 19px;
        padding-right: 18%;
        font-size: 20px;
        color: white;
        font-family: "Arial";
        font-weight: bold;
        letter-spacing: 0em;
        background-color: #165FAB;
    }

/* end prod ass */

.mainContent{
    width: 99%;
    margin-left: 5px;
    margin-top: 5px;
    margin-right: 5px;
    margin-bottom: 5px;
    border-width: 1px;
    border-color: #666666;
    border-style: solid;
    padding-left: 5px;
    padding-right: 5px;
    /*background: #f8f8f8;*/
}

.requiredBlock {
    height: 50%;
}

.saveButton{
    margin-right: 5px;
    margin-top: 10px;
    margin-bottom: 10px;
}

.lastSavedText{
    margin-right: 10px;
    color: green;
}

.ui-autocomplete-loading {
    background: white url('/img/loading.gif') right center no-repeat;
}

.ui-autocomplete {
    max-height: 200px;
    max-width: 425px;
    overflow-y: auto;
    z-index: 9997;
    /* prevent horizontal scrollbar */
    overflow-x: hidden;
}

.ui-menu{
    border: 1px solid;
    border-color: rgb(198, 204, 206);
    -webkit-box-shadow: 0px 1px 3px 0px rgba(50,50,50,0.7);
    -moz-box-shadow: 0px 1px 3px 0px rgba(50,50,50,0.7);
    box-shadow: 0px 1px 3px 0px rgba(50,50,50,0.7);
}

.ui-menu .ui-menu-item
{
    margin: 0;
    border: 1px solid;
    border-bottom: 2px solid;
    border-color: rgb(198, 204, 206);
    background-color: rgb(255,255,255);
    width: 425px;
}

.ui-menu .ui-menu-item a {
    padding-top: 10px;
    padding-bottom: 10px;
}

.ui-state-focus, .ui-widget-content .ui-state-focus{
    background: #DADADA; !important;
}

.ui-menu .ui-menu-item a.ui-state-focus{
    margin-top: -1px;
    margin-right: 0px;
    margin-bottom: -1px;
    margin-left: -1px;
}

.ui-autocomplete-over {
    /*background-color: #0A246A;
    color: white;
    padding-top: 10px;
    padding-bottom: 10px;*/
}

.ui-corner-all{
    border-radius: 0px !important;
    padding: 0;
    margin: 0;
}

.autocompleteCriticalityImage{
    position: absolute;
    top: 0px;
    left: 4px;
}

/* Header Section */

.labelHeader{
    margin-top: 0px;
    margin-bottom: 10px;
    margin-left: 0px;
    width: 475px;

    font-size: 13px;
    font-family: "Arial";
    color: rgb(39, 40, 46);
    font-weight: bold;
    line-height: 1.231;
}

.labelHeader img{
    vertical-align: middle;
    margin-right: 5px;
}

.productHeader{
    float: left;
    height: 100%;
    width: 311px;
}

.commentCodeHeader{
    float: left;
    height: 100%;
    margin-top: 4px;
    margin-left: 2px;
}

/* Table */

.productTable{
    margin-bottom: 10px;
    margin-left: 0px;
    border-collapse: separate;
    border-width: 2px;
    border-color: rgb(22, 95, 171);
    border-style: solid;
    border-radius: 4px;
    background-color: rgb(255,255,255);
    border-spacing: 0px;
    width: 100%;
    cellpadding: 0px;
}

.productImageCell{
    min-width: 77px;
    padding-top: 10px;
    padding-left: 10px;
    padding-bottom: 10px;
    vertical-align: top;
}

.productThumbnail{
    border-width: 1px;
    border-color: rgb(198,204,206);
    border-style: solid;
    background-color: rgb(255,255,255);
    width: 77px;
    height: 77px;
}

.productInfoCell{
    min-width: 206px;
    vertical-align: text-top;
    padding-right: 10px;
    padding-left: 5px;
    vertical-align: text-top;
}

.productNameField{
    font-size: 14px;
    font-family: "Arial";
    color: rgb(0,0,0);
    font-weight: bold;
    word-wrap:break-word;
    line-height: 1.143;
}

.productUPCField{
    font-size: 13px;
    font-family: "Arial";
    color: rgb(0,0,0);
    line-height: 1.231;
}

.commentSearchCell{
    width: 100%;
    min-width: 275px;
    border-right: 1px solid;
    border-left: 1px solid;
    border-color: rgb(236, 236, 236);
    background-color: rgb(255,255,255);
    padding-top: 10px;
    padding-left: 10px;
    padding-right: 23px;
    padding-bottom: 10px;
}

.commentSearchCell select{
    width: 100%;
    margin-top: 8px;
}

.commentSearchCell input{
    width: 100%;
}

.labelText{
    font-size: 10px;
    font-family: "Arial";
    color: rgb(0, 0, 0);
    font-weight: bold;
    line-height: 1.6;
    /*float: left;*/
}

.browseCommentCodes a{
    float: right;
    font-size: 10px;
    font-family: "Arial";
    color: rgb(22, 95, 171);
    font-weight: bold;
    text-decoration: underline;
    line-height: 1.6;
    height: 100%;
}

.productButtonsCell{
    min-width: 103px;
    padding-left: 20px;
}

.deleteButton,
.cloneButton,
.saveButton{
    width: 83px;
}

.productPath{
    height: 30px;
    line-height: 30px;
    padding-left: 10px;
    border-top: 1px solid;
    border-color: rgb(236, 236, 236);
    background-color: rgb(255,255,255);
    border-bottom-left-radius: 4px;
    border-bottom-right-radius: 4px;
}

.productFieldsCell{
    min-width: 301px;
    vertical-align: top;
    background-color: rgb(248,248,248);
    padding-top: 10px;
    border-top: 1px solid;
    border-color: rgb(198,204,206);
    border-bottom-left-radius: 4px;
}

.productFieldsCell div.productFieldsSection input,
.productFieldsCell div.productFieldsSection select{
    width: 125px;
    margin-top: 5px;
    margin-bottom: 20px;
}

.productFieldsCell div.productFieldsSection textarea{
    min-width: 125px;
    max-width: 125px;
    min-height: 30px;
    max-height: 30px;
}

.productFieldsSection td{
    min-width: 140px;
    max-width: 140px;
    padding-left: 10px;
    padding-bottom: 10px;
}

.productFieldLeft{
    float: left;
    width: 145px;
}

.productFieldRight{
    float: right;
    width: 145px;
}

.productFieldDate{
    float: left;
    width: 200px;
}

.productFieldOwnLine{
    float: left;
    width: 175px;
}

.commentCodeCell{
    width: 100%;
    border-top: 1px solid;
    border-left: 1px solid;
    border-top-color: rgb(198,204,206);
    border-left-color: rgb(236, 236, 236);
    background-color: rgb(248,248,248);
    border-bottom-right-radius: 4px;
    vertical-align: top;
}

/* Prevents showing the border at the top of the first comment code */
.commentCodeSection > table:nth-child(1){
    border-top: none;
}

.commentCodeTable{
    width: 100%;
    min-width: 100%;
    border-top: 1px solid;
    border-color: rgb(236, 236, 236);
}

.commentCodeDetailsTable{
    width: 100%;
    height: 100%;
    margin-top: 10px;
    margin-left: 10px;
    margin-bottom: 10px;
    border: 1px solid;
    border-color: rgb(198, 204, 206);
    background-color: rgb(253,250,216);
    padding-bottom: 10px;
}

.inactiveCommentCodeDetailsTable{
    width: 100%;
    height: 100%;
    margin-top: 10px;
    margin-left: 10px;
    margin-bottom: 10px;
    border: 1px solid;
    border-color: rgb(198, 204, 206);
    background-color: rgb(253,250,216);
    padding-bottom: 10px;


    background-color: rgb(253,250,216);
    background-image: -webkit-gradient(linear, 0 100%, 100% 0,
        color-stop(.25, rgba(255, 255, 255, 1)), color-stop(.25, transparent),
        color-stop(.5, transparent), color-stop(.5, rgba(255, 255, 255, 1)),
        color-stop(.75, rgba(255, 255, 255, 1)), color-stop(.75, transparent),
        to(transparent));
    background-image: -webkit-linear-gradient(45deg, rgba(255, 255, 255, 1) 25%, transparent 25%,
        transparent 50%, rgba(255, 255, 255, 1) 50%, rgba(255, 255, 255, 1) 75%,
        transparent 75%, transparent);
    background-image: -moz-linear-gradient(45deg, rgba(255, 255, 255, 1) 25%, transparent 25%,
        transparent 50%, rgba(255, 255, 255, 1) 50%, rgba(255, 255, 255, 1) 75%,
        transparent 75%, transparent);
    background-image: -ms-linear-gradient(45deg, rgba(255, 255, 255, 1) 25%, transparent 25%,
        transparent 50%, rgba(255, 255, 255, 1) 50%, rgba(255, 255, 255, 1) 75%,
        transparent 75%, transparent);
    background-image: -o-linear-gradient(45deg, rgba(255, 255, 255, 1) 25%, transparent 25%,
        transparent 50%, rgba(255, 255, 255, 1) 50%, rgba(255, 255, 255, 1) 75%,
        transparent 75%, transparent);
    background-image: linear-gradient(45deg, rgba(255, 255, 255, 1) 25%, transparent 25%,
        transparent 50%, rgba(255, 255, 255, 1) 50%, rgba(255, 255, 255, 1) 75%,
        transparent 75%, transparent);

    -webkit-background-size: 50px 50px;
    -moz-background-size: 50px 50px;
    background-size: 50px 50px; /* Controls the size of the stripes */
}

.warningSignCell{
    min-width: 30px;
    width: 30px;
    vertical-align: top;
}

.warningSign{
    margin-left: 7px;
    margin-top: 3px;
}

.commentDescriptionCell{
    with: 100%;
    vertical-align: top;
}

.commentDescriptionCell p{
    margin-top: 5px;
    margin-bottom: 5px;
}

.commentLevel2Text{
    font-size: 12px;
    font-family: "Arial";
    color: rgb(0,0,0);
    line-height: 1.182;
}

.commentLevel3Text{
    font-size: 12px;
    font-family: "Arial";
    font-weight: bold;
    color: rgb(0,0,0);
    line-height: 1.182;
}

.inactiveFieldLabel{
    font-size: 12px;
    font-family: "Arial";
    font-weight: bold;
    color: rgb(0,0,0);
}

.reasonField{
    margin-top: 10px;
    width: 80%;
}

.quantityCell{
    min-width: 65px;
    width: 65px;
    vertical-align: top;
}

.quantityCell input{
    margin-top: 8px;
    width: 50px;
}

.quantityLabel{
    font-size: 10px;
    font-family: Arial;
    color: rgb(0,0,0);
    font-weight: bold;
    line-height: 1.6;
    text-align: left;
}

.removeCommentCell{
    min-width: 123px;
    width: 123px;
}

.removeButtonImage{
    margin-left: 25px;
}

.removeButtonText{
    margin-left: 5px;
    font-size: 10px;
    font-family: Arial;
    color: rgb(86, 86, 96);
    font-weight: bold;
    line-height: 1.6;
}

.removeButtonImage, .removeButtonText{
    display: inline-block;
    vertical-align: middle;
}

.helpOrb {
    vertical-align: text-bottom;
}

.noResults{
    margin-top: 25px;
    margin-left: 25px;
}



/* Comment Code Dictionary */

.commentCodeDictionaryModalPopup{
    position: fixed;
    width: 100%;
    height: 100%;
    top: 0;
    left: 0;
    z-index: 4999;
    background-color: rgba(255,255,255,0.8);
}

.commentProductAssociationModalPopup{
    position: fixed;
    width: 100%;
    height: 100%;
    top: 0;
    left: 0;
    z-index: 14999;
    background-color: rgba(255,255,255,0.8);
}


.commentCodeDictionary{
    background-color: white;
    z-index: 5000;
    left: 50%;
    padding:10px;
    position: absolute;
    height: 400px;
    width: 800px;
    margin-left: -400px;
    top:50%;
    margin-top: -200px;
    overflow: auto;
    font-family: "Arial";
    box-shadow: 0px 20px 40px 0px rgba(0, 0, 0, 0.196);
}

.dicHeaderContainer{
    margin-top: 5px;
    margin-left: 30px;
}

#dictionaryDataContainer{
    padding-top: 18px;
    padding-left: 30px;
    padding-right: 30px;
    padding-bottom: 30px;
}

.dicbrowseText{
    font-size: 20px;
    font-family: "Arial";
    color: rgb(0,0,0);
    line-height: 1.2;
}

.dicProductName{
    font-size: 20px;
    font-family: "Arial";
    color: rgb(0,0,0);
    line-height: 1.2;
    font-weight: bold;
}

#dictionaryDataContainer select{
    max-width: 200px;
}

/* Refresh dialog */

.refresh_screen_overlay_show{
    position: fixed;
    top: 0%;
    left: 0%;
    width: 100%;
    height: 100%;
    background-color: rgba(255,255,255,0.8);
    z-index:20001;
}
.refresh_white_content_show {
    position: fixed;
    top: 50%;
    left: 50%;
    font-family: "Arial";
    background-color: white;
    z-index:20002;
    overflow: auto;
    width: 550px;
    height: 225px;
    margin-left: -275px;
    margin-top: -112px;
    box-shadow: 0px 20px 40px 0px rgba(0, 0, 0, 0.196);
}

.popupHeader {
    padding-top: 17px;
    padding-bottom: 19px;
    padding-left: 19px;
    padding-right: 18%;
    font-size: 20px;
    color: white;
    font-family: "Arial";
    font-weight: bold;
    letter-spacing: 0em;
    background-color: #165FAB;
}

.dialog-button-container{
    width: 100%;
    position: absolute;
    bottom: 0px;
    overflow: auto;
    height: 75px;
}

.dialog-button{
    float: right;
    right: 30px;
    margin-right: 30px;
    margin-top: 15px;
    min-width: 100px;
}

.refresh-text{
    margin-left: 31px;
    margin-right: 30px;
    font-family: "Arial";
    font-size: 12px;
    text-align: left;
    line-height: 12px;
}

.dialog-hr { 
    color: rgb(22, 95, 171);
}



