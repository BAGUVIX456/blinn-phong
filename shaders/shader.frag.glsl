#version 460 core

struct Material
{
    sampler2D texture_diffuse1;
    sampler2D texture_specular1;
    sampler2D texture_emission1;
    float shininess;
};

struct Light 
{
    vec3 position;
  
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    vec3 emission;
};

in vec3 Normal;
in vec3 FragPos;
in vec2 TexCoords;
in vec3 LightPos;

out vec4 FragColor;

uniform Material material;
uniform Light light;

void main()
{
    vec3 ambient = light.ambient * vec3(texture(material.texture_diffuse1, TexCoords));

    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(LightPos - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.texture_diffuse1, TexCoords));

    vec3 viewDir = normalize(-FragPos);
    vec3 halfwayDir = normalize(lightDir + viewDir);
    float spec = pow(max(dot(viewDir, halfwayDir), 0.0), material.shininess);
    vec3 specular = light.specular * spec * vec3(texture(material.texture_specular1, TexCoords));

    vec3 emission;
    float upperbound = 0.15;
    float lowerbound = 0.0001;
    if(diff <= lowerbound)
        emission = light.emission * vec3(texture(material.texture_emission1, TexCoords));
    else if(diff > lowerbound && diff < upperbound) {
        vec3 emi =  light.emission * ((upperbound - diff)/(upperbound - lowerbound));
        emission = emi * vec3(texture(material.texture_emission1, TexCoords));
    }
    else
        emission = vec3(0.0);

    vec3 result = ambient + diffuse + specular + emission;
    FragColor = vec4(result, 1.0);
}
