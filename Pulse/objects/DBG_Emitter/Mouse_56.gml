if !drawing_active return
e_path_plus = undefined
e_path_plus = PathRecordStop(true,true,3,false)


e_path = e_path_plus
emitter.form_path(e_path)

drawing_active = false
