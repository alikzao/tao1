

<div class="tags">
	<div class="add_map btn btn-primary"><i class=" icon-map-marker"></i> Оставить заявку</div>
	<div class=""><a href="/news/">О заявках и картах</a></div>
</div>


<script src="http://api-maps.yandex.ru/2.0/?load=package.standard&mode=debug&lang=ru-RU" type="text/javascript"></script>

<script type="text/javascript">

	$('.add_map').click(function(){
        var dialog = $('<div class="modal hide fade " style="">'+
                    '<div class="modal-header">'+
                    '<button class="close" data-dismiss="modal">×</button><h3>Место расположения</h3></div>' +
                    '<div class="modal-body" style="">' +
                        '<div class="map" style="">' +
                            '<div class="btn btn-info my_city" style="vertical-align:top; margin-top:2px;">Мой город</div> ' +
                            '<input class="typeahead" type="text" data-provide="typeahead" style="width:400px; vertical-align:top;">' +
                            '<div id="myMap" style="width: 530px; height: 300px"></div>' +
                        '</div>' +
		                '<div class="form" style="">' +
                            '<label>Адрес *<br><input></label>' +
                        '</div>' +
		            '</div>' +
                    '<div class="modal-footer"><div class="btn-group">'+
                    '<span  class="btn ok" data-dismiss="modal">Вставить</span>'+
                    '<span  class="btn cancel" data-dismiss="modal">Закрыть</span>'+
                    '<span  class="btn next" data-dismiss="modal">Далее</span>'+
                    '</div></div></div>'
                ).appendTo('body');
{#                var tube = $('').appendTo(dialog.find('.modal-body'));#}
{#                var th = $('<input class="typeahead" type="text" data-provide="typeahead" data-source="[]">').appendTo(dialog.find('.modal-body'));#}
		dialog.find('.my_city').click(function(){
			var x=document.getElementById("demo");
		    getLocation();
		});
		function get_geo_name_(coords, cb){
			ymaps.geocode(coords).then(function(res){
				res.geoObjects.each(function (obj) {
					var doc = obj.properties;
					cb(doc.get('text'));
					return false;
				});
			});
		}
		function set_geo_name(search_query){
			ymaps.geocode(search_query, {results: 100}).then(function (res) {
				myCollection.removeAll();
				myCollection = res.geoObjects;
				myMap.geoObjects.add(myCollection);
				console.log('aaa', myCollection.get(0))
				console.log('aaa', myCollection.get(0).geometry.getCoordinates())
				myMap.setCenter(myCollection.get(0).geometry.getCoordinates())
			});
		}

		dialog.find('.typeahead').keyup(function() {
			if (timeout) {
				clearTimeout(timeout);
			}
			var that = this;
			timeout = setTimeout(function() {changed_name.call(that);}, 500)
		});

		var timeout = null
		function changed_name() {
			timeout = null;
			set_geo_name($(this).val());
		}

		function get_geo_name(){

			var doc = ymaps.geolocation;
{#			return doc.region +', '+doc.country+' - '+doc.city+', '#}
			return doc.country+', '+doc.region +', '+doc.city+' - '
		}
		function getLocation() {
			$.ajax({
				type: "POST", dataType: "json", url: '/get/geo',
				data: { },
				success: function (data) {
					if (data.result=="ok") {
						myMap.setCenter(data.geo);
						dao.log(myMap);
						dao.log(ymaps);
						get_geo_name_(data.geo, function(name) {
							dialog.find('.typeahead').val(name);
						})
{#						dialog.find('.typeahead').val(get_geo_name());#}
					}
				}
			});
{#			var bef = dao.bef(dialog.find('.modal-body'));#}
{#			if (navigator.geolocation) {#}
{#				navigator.geolocation.getCurrentPosition(function(position) {#}
{#				    var sss = "Latitude: " + position.coords.latitude + "<br>Longitude: " + position.coords.longitude#}
{#					bef.click();#}
{#				    myMap.setCenter([position.coords.latitude,  position.coords.longitude] );#}
{#				});#}
{#			} else{x.innerHTML="Геолокация не подерживается вашим браузером.";}#}
		}
		myMap = new ymaps.Map('myMap', {
			center: [55.76, 37.64],
			zoom: 14,
			behaviors:['default',  "scrollZoom"]
{#			behaviors: ['ruler', 'scrollZoom']#}
		});
		myCollection = new ymaps.GeoObjectCollection();
		myMap.events.add('click', function (e) {
			var coords = e.get('coordPosition');
			get_geo_name_(coords, function(name){
				var inp = dialog.find('.typeahead');
				inp.val(name);
				inp.keyup();
			})

		});
		getLocation();
		// Добавление кнопки изменения масштаба   // Добавление списка типов карты
		myMap.controls.add("mapTools").add("zoomControl").add("typeSelector");
        dialog.modal();
        dialog.on('click', '.btn.ok', function(){ });
        dialog.on('click', '.btn.next', function(){ });
		var timeout = null;
		$('.typeahead').typeahead({
			source: function(query, proccess){
				dao.log(query);
				$.getJSON('http://geocode-maps.yandex.ru/1.x/?format=json&geocode='+query, function(data) {
					//геокодер возвращает объект, который содержит в себе результаты поиска
					//для каждого результата возвращаются географические координаты и некоторая дополнительная информация
					var result = [];
					for(var i = 0; i < data.response.GeoObjectCollection.featureMember.length; i++) {
						result.push(data.response.GeoObjectCollection.featureMember[i].GeoObject.description+' - '+data.response.GeoObjectCollection.featureMember[i].GeoObject.name);
{#						result.push({#}
{#							label: data.response.GeoObjectCollection.featureMember[i].GeoObject.description+' - '+data.response.GeoObjectCollection.featureMember[i].GeoObject.name,#}
{#							value:data.response.GeoObjectCollection.featureMember[i].GeoObject.description+' - '+data.response.GeoObjectCollection.featureMember[i].GeoObject.name,#}
{#							longlat:data.response.GeoObjectCollection.featureMember[i].GeoObject.Point.pos});#}
					}
					proccess(result)
				});
			}
		});
	});
</script>