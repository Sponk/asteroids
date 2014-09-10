<prefab>

<Entity name="Enemy1" file="../C:/Users/Yannick/Desktop/Asteroids/meshs/box.mesh">
<BoundingBox min="-5 -5 -5 " max="5 5 5 "/>
<ObjectProperties invisible="true"/>
<physics
	shape="Box"
	ghost="false"
	mass="1"
	friction="0"
	restitution="0"
	linearDamping="0.20000000298023"
	angularDamping="0.0099999997764826"
	angularFactor="0"
	linearFactor="1 1 1 "
/>
<transform
	position="463.31616210938 532.11041259766 233.49459838867 "
	rotation="0 -0 0 "
	scale="2.7262508869171 1 8.5134010314941 "
/>
<active value="true"/>
</Entity>

<Entity name="EnemyBody1" parent="Enemy1" file="../C:/Users/Yannick/Desktop/Asteroids/meshs/enemy01.mesh">
<BoundingBox min="-1.4456949234009 -0.59552294015884 -0.29486000537872 " max="0.41331899166107 1.7905607223511 0.61682188510895 "/>
<ObjectProperties invisible="false"/>
<transform
	position="487.92431640625 536.98345947266 219.53994750977 "
	rotation="90 -0 0 "
	scale="49.290843963623 49.290836334229 49.290840148926 "
/>
<active value="true"/>
</Entity></prefab>