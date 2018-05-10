.ui-autocomplete-loading {
    background: white url('/img/loading.gif') right center no-repeat;
}

.ui-autocomplete {
    max-height: 200px;
    overflow-y: auto;
    z-index: 9999;
    /* prevent horizontal scrollbar */
    overflow-x: hidden;
}

.ui-widget {
    font-family: Arial, Helvetica, sans-serif;
    font-size: 11px;
}
/* IE 6 doesn't support max-height
* we use height instead, but this forces the menu to always be this tall
*/
* html .ui-autocomplete {
    height: 200px;
}

.caseProductItem {
    margin:10px 25px;
    padding: 15px;
    border-width: 3px;
    border-color: #d0d0d0;
    
    background: #e4f3f7;
}

.productName {
    margin-top: 2px;
    margin-bottom: 2px;
    font-weight: bold;
}

.productInfo label {
    margin-right: 10px;
    margin-bottom: 10px;
}

.body{
    overflow-y: auto;
}

/* tags */
.tags{
    margin:0;
    padding:0;
    /* position:absolute;*/
    right:24px;
    bottom:-12px;
    list-style:none;
}

.tags li, .tags a{
    float:left;
    height:auto;
    line-height:24px;
    position:relative;
    font-size:11px;
    margin: 2px;
}

.tags a{
    margin-left:0px;
    padding:0 10px 0 10px;
    background:#0089e0;
    color:#fff;
    text-decoration:none;
    -moz-border-radius-bottomright:8px;
    -webkit-border-bottom-right-radius:8px;
    border-bottom-right-radius:8px;
    
    -moz-border-radius-bottomleft:8px;
    -webkit-border-bottom-left-radius:8px;
    border-bottom-left-radius:8px;
    
    -moz-border-radius-topright:8px;
    -webkit-border-top-right-radius:8px;
    border-top-right-radius:8px;
    
    -moz-border-radius-topleft:8px;
    -webkit-border-top-left-radius:8px;
    border-top-left-radius:8px;
} 

.redTags a{
    background-color:red;
}

/*
.tags a:before{
content:"";
float:left;
position:absolute;
top:0;
left:-12px;
width:0;
height:0;
border-color:transparent #0089e0 transparent transparent;
border-style:solid;
border-width:12px 12px 12px 0;      
}

.tags a:after{
content:"";
position:absolute;
top:10px;
left:0;
float:left;
width:4px;
height:4px;
-moz-border-radius:2px;
-webkit-border-radius:2px;
border-radius:2px;
background:#fff;
-moz-box-shadow:-1px -1px 2px #004977;
-webkit-box-shadow:-1px -1px 2px #004977;
box-shadow:-1px -1px 2px #004977;
}

*/


.tags a:hover {
    color: white;
    text-decoration: none;
} 

.tags a:hover:before{
    border-color:transparent #0089e0 transparent transparent;
}

.caseNotSelected {
    margin-top:25px;
    text-align: center;
}

.caseCommentCodeSection {
    overflow: hidden;
}

.pageTitle {
    margin-top:25px; 
    margin-left:25px; 
    margin-bottom:5px; 
    font-weight:bold; 
    size: 16px;
}

.searchBar {
    margin: 5px 25px;
}

#SearchContainer{
    position:absolute; 
    top: 0px; 
    left:0px; 
    right:0px; 
    bottom:0px; 
    overflow:auto;
}

.commentCodeDictionary{
    padding:25px;   
}

.commentCodeSearchBar, .productSearchBar{
    width:200px;
    padding:3px;
}