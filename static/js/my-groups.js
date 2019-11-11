function createGroupRow(groupImage, groupName) {
    var row_declaration = '<div class="row justify-content-center group-row">';
    var img_col_declaration = '<div class="col-4 text-center">';
    var img_declaration = '<img src="' + groupImage + '" alt="" class="group-image">'
    var img_col_close = "</div>"
    var name_col_declaration = '<div class="col-8 text-center align-self-center">';
    var name_declaration = '<p class="group-name">' + groupName + '</p>'
    var name_col_close = "</div>"
    var row_close = "</div>"
    return(row_declaration + img_col_declaration + img_declaration + img_col_close + name_col_declaration + name_declaration + name_col_close + row_close)
}


