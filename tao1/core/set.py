
def get_doc_forum():
	return {"_id":"des:forum", "hierarchy": ["tree"],"type": "templ", "actions": [{"title": {"ru": "","en": ""},"hint": {"ru": "Создать новую запись","en": "Create new row"},"id": "new","visible": True,"action": "this.createRow","type": "button","class": {"inrow": False,"toolbar": True,"context": True},"icon": "ui-icon-document"},{"title": {"ru": "","en": ""},"hint": {"ru": "Удалить выделенные записи","en": "Delete"},"id": "del","visible": True,"action": "this.deleteRow","type": "button","class": {"inrow": True,"toolbar": True,"context": True},"icon": "ui-icon-trash"},{"title": {"ru": "","en": ""},"hint": {"ru": "Обновить","en": "Refresh"},"id": "refresh","visible": True,"action": "this.updatelist","type": "button","class": {"inrow": False,"toolbar": True,"context": True},"icon": "ui-icon-refresh"},{"title": {"ru": "","en": ""},"hint": {"ru": "Дублировать","en": "Duplicate"},"id": "duplicate","visible": True,"action": "this.duplicate","type": "button","class": {"inrow": True,"toolbar": True,"context": True},"icon": "ui-icon-copy"},{"title": {"ru": "","en": ""},"hint": {"ru": "Редактировать","en": "Edit"},"id": "edit","visible": True,"action": "this.edit","type": "button","class": {"inrow": True,"toolbar": True,"context": True},"icon": "ui-icon-wrench"},{"title": {"ru": "","en": ""},"hint": {"ru": "Добавить поле","en": "Add field"},"id": "add_field","visible": True,"action": "this.add_field","type": "button","class": {"inrow": False,"toolbar": True,"context": False},"icon": "ui-icon-arrowreturnthick-1-s"},{"title": {"ru": "","en": ""},"hint": {"ru": "Удалить поле","en": "Delete field"},"id": "del_field","visible": True,"action": "this.del_field","type": "button","class": {"inrow": False,"toolbar": True,"context": False},"icon": "ui-icon-arrowreturnthick-1-n"},{"title": {"ru": "","en": ""},"hint": {"ru": "Перенести документ","en": "Move document"},"id": "transfer","visible": True,"action": "this.transfer","type": "button","class": {"inrow": False,"toolbar": True,"context": False},"icon": "ui-icon-transferthick-e-w"},{"hint": {"ru": "Отредактировать поле","en": "Edit field"},"title": {"ru": "","en": ""},"id": "edit_field","visible": True,"action": "this.edit_field","type": "button","class": {"inrow": False,"context": True,"toolbar": True},"icon": "ui-icon-gear"}],
			"conf": {"turn":"true", "is_doc": False,"doc_type": "des:forum","is_article": "true","comments": "on","title": {"ru": "Форум","en": "Forum"}},
			"attached_hierarchies": None, "field_map": [{"title": {"ru": "название"},"hint": {"ru": "название"},"is_translate": True,"is_editable": True,"visible": True,"oncreate": "edit","type": "string","id": "title"},{"title": {"ru": "Описание","en": "undefined"},"hint": {"ru": "Описание","en": "undefined"},"is_translate": "true","is_editable": "true","visible": "true","relation": "com:des:library","oncreate": "edit","type": "string","id": "descr"},{"title": {"ru": "Содержание"},"hint": {"ru": "Содержание"},"is_translate": True,"is_editable": True,"visible": False,"oncreate": "edit","type": "rich_edit","id": "body"},{"title": {"ru": "Дата"},"hint": {"ru": "Дата"},"is_translate": False,"is_editable": True,"visible": True,"oncreate": "edit","type": "date","id": "date"},{"hint": {"ru": "","en": ""},"title": {"ru": "Опубликовать","en": "Published"},"is_editable": "true","visible": "true","relation": "com:des:2","oncreate": "edit","type": "checkbox","id": "published"},{"title": {"ru": "Автор","en": "Author"},"hint": {"ru": "","en": ""},"is_editable": "true","visible": "true","relation": "des:users","oncreate": "edit","type": "select","id": "user"},{"hint": {"ru": "Показ на главной странице","en": ""},"title": {"ru": "Главная","en": "Home"},"is_editable": "true","visible": "true","relation": "com:des:library","oncreate": "edit","type": "checkbox","id": "home"},{"hint": {"ru": "","en": ""},"title": {"ru": "Простой стиль","en": "Simple style"},"is_editable": "true","visible": "true","relation": "com:des:library","oncreate": "edit","type": "checkbox","id": "simple_style"}]}


def get_doc_obj():
	return {"_id":"des:obj", "hierarchy": ["tree"],"type": "templ", "actions": [{"title": {"ru": "","en": ""},"hint": {"ru": "Создать новую запись","en": "Create new row"},"id": "new","visible": True,"action": "this.createRow","type": "button","class": {"inrow": False,"toolbar": True,"context": True},"icon": "ui-icon-document"},{"title": {"ru": "","en": ""},"hint": {"ru": "Удалить выделенные записи","en": "Delete"},"id": "del","visible": True,"action": "this.deleteRow","type": "button","class": {"inrow": True,"toolbar": True,"context": True},"icon": "ui-icon-trash"},{"title": {"ru": "","en": ""},"hint": {"ru": "Обновить","en": "Refresh"},"id": "refresh","visible": True,"action": "this.updatelist","type": "button","class": {"inrow": False,"toolbar": True,"context": True},"icon": "ui-icon-refresh"},{"title": {"ru": "","en": ""},"hint": {"ru": "Дублировать","en": "Duplicate"},"id": "duplicate","visible": True,"action": "this.duplicate","type": "button","class": {"inrow": True,"toolbar": True,"context": True},"icon": "ui-icon-copy"},{"title": {"ru": "","en": ""},"hint": {"ru": "Редактировать","en": "Edit"},"id": "edit","visible": True,"action": "this.edit","type": "button","class": {"inrow": True,"toolbar": True,"context": True},"icon": "ui-icon-wrench"},{"title": {"ru": "","en": ""},"hint": {"ru": "Добавить поле","en": "Add field"},"id": "add_field","visible": True,"action": "this.add_field","type": "button","class": {"inrow": False,"toolbar": True,"context": False},"icon": "ui-icon-arrowreturnthick-1-s"},{"title": {"ru": "","en": ""},"hint": {"ru": "Удалить поле","en": "Delete field"},"id": "del_field","visible": True,"action": "this.del_field","type": "button","class": {"inrow": False,"toolbar": True,"context": False},"icon": "ui-icon-arrowreturnthick-1-n"},{"title": {"ru": "","en": ""},"hint": {"ru": "Перенести документ","en": "Move document"},"id": "transfer","visible": True,"action": "this.transfer","type": "button","class": {"inrow": False,"toolbar": True,"context": False},"icon": "ui-icon-transferthick-e-w"},{"hint": {"ru": "Отредактировать поле","en": "Edit field"},"title": {"ru": "","en": ""},"id": "edit_field","visible": True,"action": "this.edit_field","type": "button","class": {"inrow": False,"context": True,"toolbar": True},"icon": "ui-icon-gear"}],
			"conf": {"turn":"true", "is_doc": False,"doc_type": "des:obj","is_article": "true","comments": "on","title": {"ru": "Материалы","en": "Materials"}},
			"attached_hierarchies": None, "field_map": [{"title": {"ru": "название"},"hint": {"ru": "название"},"is_translate": True,"is_editable": True,"visible": True,"oncreate": "edit","type": "string","id": "title"},{"title": {"ru": "Описание","en": "undefined"},"hint": {"ru": "Описание","en": "undefined"},"is_translate": "true","is_editable": "true","visible": "true","relation": "com:des:library","oncreate": "edit","type": "string","id": "descr"},{"title": {"ru": "Содержание"},"hint": {"ru": "Содержание"},"is_translate": True,"is_editable": True,"visible": False,"oncreate": "edit","type": "rich_edit","id": "body"},{"title": {"ru": "Дата"},"hint": {"ru": "Дата"},"is_translate": False,"is_editable": True,"visible": True,"oncreate": "edit","type": "date","id": "date"},{"hint": {"ru": "","en": ""},"title": {"ru": "Опубликовать","en": "Published"},"is_editable": "true","visible": "true","relation": "com:des:2","oncreate": "edit","type": "checkbox","id": "published"},{"title": {"ru": "Автор","en": "Author"},"hint": {"ru": "","en": ""},"is_editable": "true","visible": "true","relation": "des:users","oncreate": "edit","type": "select","id": "user"},{"hint": {"ru": "Показ на главной странице","en": ""},"title": {"ru": "Главная","en": "Home"},"is_editable": "true","visible": "true","relation": "com:des:library","oncreate": "edit","type": "checkbox","id": "home"},{"hint": {"ru": "","en": ""},"title": {"ru": "Простой стиль","en": "Simple style"},"is_editable": "true","visible": "true","relation": "com:des:library","oncreate": "edit","type": "checkbox","id": "simple_style"}]}
	

def get_doc_ware():
	return {"id":"des:ware", "hierarchy": [ "tree:ware" ], "type": "templ", "actions": [ { "hint": { "ru": "Создать новую запись", "en": "Create new row" }, "title": { "ru": "", "en": "" }, "class": { "inrow": False, "context": True, "toolbar": True }, "visible": True, "action": "this.createRow", "type": "button", "id": "new", "icon": "ui-icon-document" }, { "hint": { "ru": "Удалить выделенные записи", "en": "Delete" }, "title": { "ru": "", "en": "" }, "class": { "inrow": True, "context": True, "toolbar": true }, "visible": true, "action": "this.deleteRow", "type": "button", "id": "del", "icon": "ui-icon-trash" }, { "hint": { "ru": "Обновить", "en": "Refresh" }, "title": { "ru": "", "en": "" }, "class": { "inrow": False, "context": True, "toolbar": True }, "visible": True, "action": "this.updatelist", "type": "button", "id": "refresh", "icon": "ui-icon-refresh" }, { "hint": { "ru": "Дублировать", "en": "Duplicate" }, "title": { "ru": "", "en": "" }, "class": { "inrow": True, "context": True, "toolbar": True }, "visible": True, "action": "this.duplicate", "type": "button", "id": "duplicate", "icon": "ui-icon-copy" }, { "hint": { "ru": "Редактировать", "en": "Edit" }, "title": { "ru": "", "en": "" }, "class": { "inrow": True, "context": True, "toolbar": True }, "visible": True, "action": "this.edit", "type": "button", "id": "edit", "icon": "ui-icon-wrench" }, { "hint": { "ru": "Добавить поле", "en": "Add field" }, "title": { "ru": "", "en": "" }, "class": { "inrow": False, "context": False, "toolbar": True }, "visible": True, "action": "this.add_field", "type": "button", "id": "add_field", "icon": "ui-icon-arrowreturnthick-1-s" }, { "hint": { "ru": "Удалить поле", "en": "Delete field" }, "title": { "ru": "", "en": "" }, "class": { "inrow": False, "context": False, "toolbar": True }, "visible": True, "action": "this.del_field", "type": "button", "id": "del_field", "icon": "ui-icon-arrowreturnthick-1-n" }, { "hint": { "ru": "Перенести документ", "en": "Move document" }, "title": { "ru": "", "en": "" }, "class": { "inrow": false, "context": false, "toolbar": true }, "visible": true, "action": "this.transfer", "type": "button", "id": "transfer", "icon": "ui-icon-transferthick-e-w" }, { "visible": true, "icon": "ui-icon-custom custom-print_excel", "hint": "Распечатать excel", "action": "this.print_excel", "title": "", "type": "button", "id": "print_excel", "class": { "inrow": false, "toolbar": true, "context": false } } ],
		"conf": {"turn":"true", "is_doc": 'false', "title": { "ru": "Товары", "en": "Ware" }, "type": "templ", "comments": "on", "doc_type": "des:ware" },
		"attached_hierarchies": None, "field_map": [ { "hint": { "ru": "Отображение на главной странице сайта", "en": "" }, "is_translate": False, "is_editable": True, "visible": False, "title": { "ru": "Главная", "en": "" }, "oncreate": "edit", "type": "checkbox", "id": "home" }, { "title": { "ru": "Название", "en": "" }, "hint": { "ru": "Название товара", "en": "" }, "is_translate": True, "is_editable": "true", "visible": "true", "oncreate": "edit", "type": "string", "id": "title" }, { "hint": { "ru": "Описание товара", "en": "" }, "is_translate": True, "is_editable": "true", "visible": "true", "title": { "ru": "Описание", "en": "" }, "oncreate": "edit", "type": "string", "id": "descr" }, { "hint": { "ru": "Страна производитель", "en": "" }, "is_translate": True, "is_editable": "true", "visible": "true", "relation": "Country", "title": { "ru": "Страна", "en": "" }, "oncreate": "edit", "type": "select", "id": "country" }, { "title": { "ru": "Цена", "en": "" }, "hint": { "ru": "Цена товара", "en": "" }, "is_translate": False, "is_editable": "true", "visible": "true", "oncreate": "edit", "type": "string", "id": "price" }]}


def get_doc_des(id, name_ru, name_en, owner, is_doc=False):
	doc = {
	"_id": "des:"+id,
	"hierarchy": [ "tree:"+id ], "attached_hierarchies": None,
	"events": {},
	"type": "templ",
	"conf":{"comments": "on", "title": {"ru":name_ru, "en":name_en}, "doc_type":"des:"+ id, "owner":owner, "turn":"true"},
	"doc": [
		{"title": {"ru": u"Опубликовано","en": "Published"},"hint": {"ru": "","en": ""},"is_translate": "false","is_editable": "true","visible": "true","relation": "des:web_order","oncreate": "edit","type": "checkbox","id": "pub"},
		{"title": {"ru": u"Автор","en": "Author"},"hint": {"ru": "","en": ""},"is_editable": "true","visible": "true","relation": "des:users","oncreate": "edit","type": "select","id": "user"},
		{"title": {"ru": u"Тэги","en": "Tags"},"hint": {"ru": "","en": ""},"is_translate": "true","is_editable": "true","visible": "true","relation": "com:des:obj","oncreate": "edit","type": "string","id": "tags"},
		{"title": {"ru": u"Название"},"hint": {"ru": u"Название"},"is_translate": True,"is_editable": True,"visible": True,"oncreate": "edit","type": "string","id": "title"},
		{"title": {"ru": u"Содержание"},"hint": {"ru": u"Содержание"},"is_translate": True,"is_editable": True,"visible": False,"oncreate": "edit","type": "rich_edit","id": "body"},
		{"title": {"ru": u"Дата"},"hint": {"ru": u"Дата"},"is_translate": False,"is_editable": True,"visible": True,"oncreate": "edit","type": "date","id": "date"},
		{"title": {"ru": u"Анонс","en": "Description"},"hint": {"ru": "","en": ""},"is_translate": "true","is_editable": "true","visible": "true","relation": "des:web_order","oncreate": "edit","type": "string","id": "descr"},
		{"hint":  {"ru": "","en": ""},"is_translate": "false","is_editable": "false","visible": "true","relation": "com:des:obj","title": {"ru": "Второй id","en": "Second id"},"oncreate": "edit","type": "string","id": "rev"}
	]
	}
	if is_doc=='doc' :
		doc['conf'].update({"is_doc":True, "turn":"true"})
		doc['actions'].append(
				{"hint": u"Провести документ", "title": "", "class": { "inrow": False, "context": False, "toolbar": True},
				"visible": True, "action": "this.checkout", "type": "button", "id": "check", "icon": "icon-check"}
		)
	elif is_doc!='doc' and owner=='_' :
		doc['conf'].update({"is_doc":False, "turn":"true"})

	if is_doc=='doc' and owner=='_':
		aaa = [
			{"hint": {"ru": "", "en": ""}, "title": {"ru": "Номер", "en": "Number" },			"is_editable":"true", "visible":"true", "oncreate":"edit", "type":"string", "id":"number" },
			{"hint": {"ru": "", "en": ""}, "title": {"ru": "Статус", "en": "Status" },		  "is_editable":"true", "visible":"true", "oncreate":"edit", "type":"string", "id":"status" }, 
			{"hint": {"ru": "", "en": ""}, "title": {"ru":"Контерагент", "en":"Counteragent"},  "is_editable":"true", "visible":"true", "relation":"des:counteragent", "oncreate": "edit", "type":"select", "id":"counteragent"},
			{"hint": {"ru": "", "en": ""}, "title": { "ru": "Предприятие", "en": "Enterprise"}, "is_editable": "true", "visible": "true", "relation": "des:enterprise", "oncreate": "edit", "type": "select", "id":"enterprise" },
			{"hint": {"ru": "", "en": ""}, "title": {"ru": "Сумма", "en": "Amount"},			"is_editable": "true", "visible": "true", "oncreate": "hide", "type": "string", "id": "amount" },
			{"hint": {"ru": "", "en": ""}, "title": { "ru": "Сумма с НДС", "en": "Amount VAT"}, "is_editable": "true", "visible": "true", "relation": "des: ", "oncreate": "hide", "type": "string", "id": "amount_vat" }
		]
		for res in aaa:
			doc['field_map'].append(res)
	elif is_doc=='doc' and owner !='_':
		aaa = [
			{"hint": {"ru": "Название товара", "en": "Title ware"}, "title": {"ru": "Название", "en": "title"}, "is_editable": "true", "visible": "true", "relation": "des: ware", "oncreate": "edit", "type": "select", "id": "title"},
			{"hint": {"ru": "Количество","en": "Quantity"}, "title": {"ru": "Количество",  "en": "Quantity"},	"is_editable": "true", "visible": "true", "relation": "des: 1", "oncreate": "edit", "type": "string", "id": "quantity"},
			{"hint": {"ru": "", "en":""}, "title": {"ru": "Цена", "en": "Price"},								"is_editable": "true", "visible": "true", "relation": "des: 1", "oncreate": "edit", "type": "string","id": "price" },
			{"hint": {"ru": "", "en":""}, "title": {"ru": "Цена с НДС","en": "Price VAT"},					  "is_editable": "true","relation": "des: ","oncreate": "edit","type": "string","id": "price_vat"},
			{"hint": {"ru": "", "en":""}, "title": {"ru": "Сумма", "en": "Amount"  },							"is_editable": "false","visible": "true","relation": "des: 1","oncreate": "hide","type": "string","id": "amount"},
 			{"hint": {"ru": "", "en":""}, "title": {"ru": "Сумма с НДС", "en": "Amount VAT"  },				 "is_editable": "true", "visible": "true","relation": "des: ","oncreate": "hide","type": "string","id": "amount_vat"}
		]
		for res in aaa:
			doc['field_map'].append(res)
	return doc


def get_field_date():
	doc = {"hint": {"ru": "", "en": ""}, "title": {"ru": "Дата", "en": "Date" }, "visible": False, "oncreate": "edit", "type": "date", "is_editable": False, "id": "date" }, 
	return doc


def get_field_user():
	doc = {"hint": {"ru": "", "en": ""}, "title": {"ru": "Пользователь", "en": "User" }, "visible": False, "oncreate": "none", "type":"select", "relation": "des:users", "is_editable": False, "id": "user" }
	return doc


def get_field_title():
	doc = {"hint": {"ru": "Название", "en": "Title"}, "title": {"ru": "Название", "en": "Title"}, "is_editable": "true", "visible": "true", "oncreate": "edit", "id": "title"},
	return doc


def get_doc_permissions(id):
	return {"des:"+id: {"edit":"true", "delete":"true", "create":"true", "move":"true", "view":"true" }}


def get_doc_role(data, domain):
	return {
		"_id": "role:"+data['id'],
		"title":data['title'],
		"type": "group",
#		"users": { "user:"+get_domain(): "true" },
		"users": { "user:"+domain: "true" },
		"permissions": {  }
	}
	






