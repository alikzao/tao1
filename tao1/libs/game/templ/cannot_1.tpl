<img src="//habrastorage.org/files/46a/96a/608/46a96a6088d74d20a602501ce53164e0.jpg"/>

Сразу оговорюсь ничего холиварного, кроме названия, в статье нет. Все задумывалось как просто обзор разных дополнений и библиотек к играм для <font color="green">three.js</font>, а <font color="DarkMagenta">babylon.js</font> описать как еще одну хорошую библиотеку. Но потом, в процессе разработки, стало понятно что во многом часто происходит дублирование. Например система частиц в <code>three</code> выражена неплохим дополнением а в <code>babylon</code> она встроена в саму библиотеку и они немного по разному настраиваются и работают. В итоге получился скорее обзор одного и того же в двух разных фреймворках для <code>WebGL</code>.
<habracut text="Далее подробней в примерах"/>
<a href="#0">Введение</a>
<a href="#1">1. Базовые элементы</a>
<a href="#2">2. Группировка</a>
<a href="#3">3. Движение</a>
<a href="#4">4. Частицы</a>
<a href="#5">5. Анимация</a>
<a href="#6">6. Картография</a>
<a href="#7">7. Статические колизии</a>
<a href="#8">8. Динамические коллизиии</a>
<a href="#9">9. Импорт моделей</a>
<a href="#10">10. Встраивание физических движков.</a>
<a href="#11">11. Процедурные текстуры. </a>

<h3><anchor>Введение</anchor></h3>
Когда я начинал писать свою первую игрушку на <code>three.js</code>  я и не подозревал что на самом деле <code>three.js</code> это верхушка айсберга и для отрисовки <code>WebGL</code> c помощью <code>javascript</code>  есть десятки библиотек и что <code>three.js</code> просто одна из них.

По понятным причинам сделать детальный разбор всех имеющихся просто невозможно. Поэтому в введении ограничусь просто небольшим обзором самых распространённых и со свободной лицензией.

<ul>
<li>http://three.js Первопроходец и самая известная библиотека.</li>
<li>http://babylon.js Достойный конкурент для <code>three.js</code></li>
<li>http://turbulenz.com Часто упоминается в числе трех самых популярных наряду с <code>babylon</code> и <code>three.js</code>, ну и кол-во звездочек на <code>github</code> говорит само за себя.
В основном <code>turbulenz</code> популяризуется как библиотека для создания игрушек, в частности привлек внимание  <a href="https://ga.me/games/quake4-multiplayer"> quake </a></li>
</ul>

Далее следует ряд менее популярных фреймворков:

<ul>
<li>https://playcanvas.com Симпатичный фреймворк, симпатичный демки. С <code>Gangnam Style</code> у них классная <a href="http://apps.playcanvas.com/will/doom3/gangnamstyle"> демка </a> получилась.</li>
<li>http://scenejs.org/ Симпатичная библиотека, наверно с препарироваными примерами. Синтаксис больше похож на инициализацию <code>jquery</code> плагинов.</li>

<li>http://voxel.js</li> не совсем аналог <code>three.js</code> но достоин для упоминания. Чаще всего о нем говорят как о библиотеке для создания аналогов Minecraft, в принципе в демках там ничего другого и нет особо.
<li> http://www.senchalabs.org/philogl/  на первый взгляд примеры не произвели ожидаемого впечатления</li>
<li>http://www.glge.org/  Еще одна библитека.</li>
<li>http://www.goocreate.com/blog/ Он-лайн редактор, импортер.</li>
<li>http://www.kickjs.org/ просто упомяну здесь для статистики.</li>
</ul>
Пожалуй это наверно и все что можно перечислить, отдельно хочу упомянуть что некоторые движки для реализации реалистичной физики по сути являются сами по себе уже фреймворками но о них чуть ниже.


<h3><anchor>1</anchor>1. Базовые элементы</h3>
<h4>Сцена</h4>
В <font color="green">three.js</font> инициализация происходит с добавления <code>renderer</code> в <code>document.body</code>
<source lang="javascript">
var renderer =  new THREE.WebGLRenderer( {antialias:true} ) ;
renderer.setSize( window.innerWidth, window.innerHeight );
document.body.appendChild( renderer.domElement );
</source>
А сцена создается отдельно как бы. И в неё уже добавляются все элементы сцены.
<source lang="javascript">
var scene = new THREE.Scene();
scene.add( sceneMesh );
</source>
В <font color="DarkMagenta">babylon.js</font> все начинается с создания элемента <code>canvas</code>:
<source lang="javascript">
<canvas id="renderCanvas"></canvas>
</source>
Создания экземпляра <code>BABYLON</code>, <code>engine</code> и добавление в него <code>canvas</code>, <code>engine</code> это аналог <code>renderer</code> и также опцией можно включить для него <code>antialiasing</code>.
<source lang="javascript">
var canvas = document.getElementById("renderCanvas");
var engine = new BABYLON.Engine(canvas, true);
</source>
Сцена наследует <code>engine</code>.
<source lang="javascript">
scene = new BABYLON.Scene(engine);
</source>
После этого в <font color="green">three.js</font> <code>renderer</code> вызывается рекурсивно в любой функции с наличием <code>requestAnimationFrame</code>, а в <font color="DarkMagenta">babylon.js</font> колбеком  в <code>engine.runRenderLoop</code>.
В <font color="green">three.js</font>, чаще все в <code>animate</code> добавляется все логика движений например полет пуль, вращение объектов, беготня ботов и все такое.
<source lang="javascript">
function animate() {
    requestAnimationFrame(animate);
    renderer.render(scene, camera);
}
</source>
Как это выглядит в <font color="DarkMagenta">babylon.js</font>, тут как правило иногда только добавляют подсчет частоты кадров, вершин, кол-ва частиц и тд. Проще говоря статистику. Для различных анимаций есть красивый хук, подробней об этом в главе про <a href="#5">анимацию</a>
<source lang="javascript">
 engine.runRenderLoop(function () {
        scene.render();
        stats.innerHTML = "FPS: <b>" +  BABYLON.Tools.GetFps().toFixed() + "</b>
});
</source>
<h4>Примитивы</h4>
После инициализации сцены первое что можно сделать это создать примитивы.
Тут все более менее похоже у <code>babylon</code> выглядит компактнее добавление на сцену объекта просто опцией, а у <code>htree</code> простые манипуляции с назначениями материалов выглядят компактнее.
<font color="green">three.js</font>
<source lang="javascript">
var sphere = BABYLON.Mesh.CreateSphere("sphere1", 16, 2, scene);
sphere.material = new BABYLON.StandardMaterial("texture1", scene);
sphere.material.diffuseColor = new BABYLON.Color3(1, 0, 0); //Red
sphere.material.alpha = 0.3;
</source>
<font color="DarkMagenta">babylon.js</font>
<source lang="javascript">
var cube = new THREE.Mesh( new THREE.BoxGeometry( 1, 1, 1 ), new THREE.MeshBasicMaterial( { color: 0x00ff00 } ) );
scene.add( cube );
</source>
Позиция для координат по отдельности указывается одинаково:
<source lang="javascript">
 mesh.position.x = 1;
 mesh.position.y = 1;
 mesh.position.z = 1;
</source>
А чтоб сразу задать есть отличия, например в <font color="green">three.js</font> можно написать вот так:
<source lang="javascript">
mesh.position.set(1, 1, 1);
mesh.rotation.set(1, 1, 1);
</source>
А в <font color="DarkMagenta">babylon.js</font> если не подсматривать в отладчик только так:
<source lang="javascript">
mesh.position = new BABYLON.Vector3(1, 1, 1);
</source>
<h4>Камеры</h4>
Основных камер у обоих библиотек самых используемых камер по две, хотя уесть дополнительные у <code>babylon</code> к примеру есть с разными фильтрами и применительно к планшетам и прочим девайсам.
<font color="DarkMagenta">babylon.js</font>
<ul>
<li><code>FreeCamera</code> - По сути показывает перспективную проекцию, но с возможностью назначить клавиши для управления, что удобно использовать в играх от первого лица подробнее в  главе про <a href="#2">Передвижение персонажа</a> </li>
<li><code>ArcRotateCamera</code> - Камера предполагает вращение вокруг заданной оси, с помощью курсора мыши, или сенсора если предварительно подключить hand.js</li>
</ul>
<font color="gren">three.js</font>
<ul>
<li><code>PerspectiveCamera</code> - камера перспективной проекции, немного упрощенный аналог <code>FreeCamera</code>. Зависит от пропорций и поля зрения и показывает реальный мир.</li>
<li><code>OrthographicCamera</code> - камера ортогональной проекции, показывает все объекты сцены одинаковыми, без пропорций.</li>
</ul>
Возможность повращать мышкой сцену в <code>three.js</code> помогает плагин <a href="https://gist.github.com/mrflix/8351020">OrbitControls.js</a>. В <code>babylon</code> похожая возможность есть к примеру в <code>ArcRotateCamera</code>.
<source lang="javascript">
new THREE.PerspectiveCamera( 45, width / height, 1, 1000 );
new THREE.OrthographicCamera( width / - 2, width / 2, height / 2, height / - 2, 1, 1000 );
</source>
Из дополнительного тут есть еще <code>CombinedCamera</code> -  позволяет устанавливать фокусное расстояние объектива и переключаться между перспективной и ортогональной проекцией.
<source lang="javascript">
CombinedCamera( width, height, fov, near, far, orthoNear, orthoFar )
</source>
<h4>Освещение</h4>
С освещением каких то особых различий нет:
<font color="DarkMagenta">babylon.js</font>
<ol>
<li><code>Point Light</code> - Точечный свет, имитирует световое пятно. </li>
<li><code>Directional Light</code> - Направленный немного расеяный свет.</li>
<li><code>Spot Light</code> - Больше похож на имитацию фонарика, например может имитировать движение светила.</li>
<li><code>HemisphericLight</code> - подходит для имитации реалистичного окружающей среды, равномерно освещает.</li>
</ol>
<source lang="javascript">
//Point Light
new BABYLON.PointLight("Omni0", new BABYLON.Vector3(1, 10, 1), scene);
//Directional Light
new BABYLON.DirectionalLight("Dir0", new BABYLON.Vector3(0, -1, 0), scene);
//Spot Light
new BABYLON.SpotLight("Spot0", new BABYLON.Vector3(0, 30, -10), new
BABYLON.Vector3(0, -1, 0), 0.8, 2, scene);
//Hemispheric Light
new BABYLON.HemisphericLight("Hemi0", new BABYLON.Vector3(0, 1, 0), scene);
</source>

<font color="green">three.js</font>
<ol>
<li><code>AmbientLight</code> - представляет общее освещение, применяемое ко всем объектам сцены.</li>
<li><code>AreaLight</code> представляет пространственный источник света, имеющий размеры — ширину и высоту и ориентированный в пространстве</li>
<li><code>DirectionalLight</code> - представляет источник прямого (направленного) освещения — поток параллельных лучей в направлении объекта.</li>
<li><code>HemisphereLight</code> - представляет полусферическое освещение</li>
<li><code>SpotLight</code> - представляет прожектор.</li>
</ol>
<source lang="javascript">
var ambientLight = new THREE.AmbientLight( 0x404040 ); // soft white light

areaLight1 = new THREE.AreaLight( 0xffffff, 1 );
areaLight1.position.set( 0.0001, 10.0001, -18.5001 );
areaLight1.width = 10;

var directionalLight = new THREE.DirectionalLight( 0xffffff, 0.5 );
directionalLight.position.set( 0, 1, 0 );

var pointLight = new THREE.PointLight( 0xff0000, 1, 100 );
pointLight.position.set( 50, 50, 50 );

var spotLight = new THREE.SpotLight( 0xffffff );
spotLight.position.set( 100, 1000, 100 );
</source>
<h4>Материалы</h4>
Подход к материалам тут уже довольно сильно разнится, если у <code>three</code> есть как бы список возможных материалов, то у <code>babylon</code> по сути есть только один материал и к нему применяются разные свойства: прозрачноcти, накладывания текстур с последующим их смещениям по осям и тд.
пара примеров:
<font color="DarkMagenta">babylon.js</font>
<source lang="javascript">
// создание материала и назначение текстуры
var materialSphere6 = new BABYLON.StandardMaterial("texture1", scene);
materialSphere6.diffuseTexture = new BABYLON.Texture("./tree.png", scene);

// создание материала и назначение ему цвета и прозрачности
var materialSphere2 = new BABYLON.StandardMaterial("texture2", scene);
materialSphere2.diffuseColor = new BABYLON.Color3(1, 0, 0); //Red
materialSphere2.alpha = 0.3;
</source>

<font color="green">three.js</font>
<ul>
<li><code>MeshBasicMaterial</code> - просто назначает любой цвет примитиву  </li>
<li><code>MeshNormalMaterial</code> -  материал со свойствами shading, совмещает в себе смешение цветов. </li>
<li><code>MeshDepthMaterial</code> - материал со свойствами wireframe, выглядит черно-белым</li>
<li><code>MeshLambertMaterial</code> - материал для не блестящих поверхностей</li>
<li><code>MeshPhongMaterial</code> - материал для блестящих поверхностей</li>
<li><code>MeshFaceMaterial</code> - может комбинировать другие виды материалов назначать на каждый полигон свой материал.</li>
</ul>
Для примера базовая сцена для обоих библиотек:
<spoiler title="three.js">
<source lang="javascript">
<html>
    <head>
	<title>My first Three.js app</title>
	<style>
		body { margin: 0; }
		canvas { width: 100%; height: 100% }
	</style>
    </head>
    <body>
	<script src="js/three.min.js"></script>
	<script>
  	     var scene = new THREE.Scene();
             var camera = new THREE.PerspectiveCamera( 75, window.innerWidth/window.innerHeight, 0.1, 1000 );
	     var renderer = new THREE.WebGLRenderer();
	     renderer.setSize( window.innerWidth, window.innerHeight );
	     document.body.appendChild( renderer.domElement );
	     var geometry = new THREE.BoxGeometry( 1, 1, 1 );
	     var material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
	     var cube = new THREE.Mesh( geometry, material );
	     scene.add( cube );
	     camera.position.z = 5;
	     var render = function () {
		    requestAnimationFrame( render );
		    renderer.render(scene, camera);
	     };
	     render();
	</script>
    </body>
</html>
</source>
</spoiler>
<spoiler title="babylon.js">
<source lang="javascript">
<!doctype html>
<html>
<head>
   <meta charset="utf-8">
   <title>Babylon - Basic scene</title>
   <style>  #renderCanvas {   width: 100%;  height: 100%;  }   </style>
   <script src="babylon.js"></script>
</head>
<body>
   <canvas id="renderCanvas"></canvas>

   <script type="text/javascript">
      var canvas = document.querySelector("#renderCanvas");
      var engine = new BABYLON.Engine(canvas, true);
      var createScene = function () {
          var scene = new BABYLON.Scene(engine);
          scene.clearColor = new BABYLON.Color3(0, 1, 0);
          var camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);
          camera.setTarget(BABYLON.Vector3.Zero());
          camera.attachControl(canvas, false);
          var light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
          light.intensity = .5;
          var sphere = BABYLON.Mesh.CreateSphere("sphere1", 16, 2, scene);
          sphere.position.y = 1;
          var ground = BABYLON.Mesh.CreateGround("ground1", 6, 6, 2, scene);
          return scene;
      };
      var scene = createScene();
      engine.runRenderLoop(function () {  scene.render();   });
   </script>

</body>
</html>


    10.20
    10.40
    19.39
    19.47
    31,14
    31,32
==
    49.34  гуманитарка
    49.40


    avconv -i in.mp4 -ss 00:02:05 -t 00:00:43 -q 1 -threads 8 -strict experimental -y out.mp4

