#version 130

#ifdef GL_ES
precision highp float;
#endif

uniform mat4 TextureMatrix[8];

varying vec2 texcoord;
attribute vec2 Vertex;
attribute vec2 TexCoord;
uniform mat4 ProjModelViewMatrix;


void main(void)
{
	texcoord = TexCoord;
	gl_Position = ProjModelViewMatrix * vec4(Vertex.x, Vertex.y, 0.0, 1.0);
}
