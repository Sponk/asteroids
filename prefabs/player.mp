<prefab>

<Entity name="Player" file="../C:/Users/Yannick/Desktop/Asteroids/meshs/box.mesh">
<BoundingBox min="-5 -5 -5 " max="5 5 5 "/>
<ObjectProperties invisible="true"/>
<physics
	shape="Box"
	ghost="false"
	mass="1"
	friction="0.5"
	restitution="0"
	linearDamping="0.0099999997764826"
	angularDamping="0.0099999997764826"
	angularFactor="0"
	linearFactor="0 0 0 "
/>
<transform
	position="0 -13.072006225586 47.264316558838 "
	rotation="0 -0 0 "
	scale="2.7262508869171 1 8.5134010314941 "
/>
<active value="true"/>
</Entity>

<Entity name="Body" parent="Player" file="../C:/Users/Yannick/Desktop/Asteroids/meshs/player.mesh">
<BoundingBox min="-0.29898101091385 -0.27094998955727 -0.953389108181 " max="0.50678598880768 0.84266501665115 0.7393559217453 "/>
<ObjectProperties invisible="false"/>
<transform
	position="0.025689462199807 -12.918204307556 55.487487792969 "
	rotation="0 -0 0 "
	scale="51.897087097168 51.89709854126 51.897106170654 "
/>
<active value="true"/>
</Entity>

<Entity name="GunExit" parent="Player" file="../C:/Users/Yannick/Desktop/Asteroids/meshs/box.mesh">
<BoundingBox min="-5 -5 -5 " max="5 5 5 "/>
<ObjectProperties invisible="true"/>
<transform
	position="14.351364135742 28.324161529541 69.36408996582 "
	rotation="0 -0 0 "
	scale="0.36059847474098 0.36059799790382 0.36060214042664 "
/>
<active value="true"/>
</Entity></prefab>