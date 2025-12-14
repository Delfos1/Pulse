if !drawing_active return
e_path_plus = undefined
var _result = PathRecordStop(true,true,3,false)

drawing_active = false

if _result == undefined {return}

e_path_plus = _result
e_path = e_path_plus
emitter.form_path(e_path)


