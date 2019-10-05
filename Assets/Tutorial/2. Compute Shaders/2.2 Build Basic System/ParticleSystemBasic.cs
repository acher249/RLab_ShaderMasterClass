using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleSystemBasic : MonoBehaviour
{
    [SerializeField]
    int numParticles = 10000;

    struct Particle
    {
        public Vector3 Position;
        public Vector3 Velocity;

        public static int stride = 6 * sizeof(float);
    }

    ComputeBuffer ParticleBuffer;
    ComputeBuffer ArgsBuffer;

    public Material mat;
    public Mesh mesh;

// only really care about index 1 is the instance count of the particles
    private uint[] args = new uint[5] {0,0,0,0,0};

    /*
     * InitializeParticles()
     * 
     * TODO: 
     * 1) Setup initial data of particles
     * 2) Load data on the GPU in a compute buffer
     * 
     * */
    void InitializeParticles()
    {
        List<Particle> particles = new List<Particle>();

        for(int i=0; i< numParticles; i++)
        {
            // the data type of the particle struct will have to match on the cpu here
            // and the gpu side later..
            // could add more parameters in the struct..
            Particle p = new Particle
            {
                Position = Random.insideUnitSphere,
                Velocity = Vector3.zero,

            };

            particles.Add(p);

        }

        // this is how to create a new block of data for the GPU
        // stride needed to allocate memory on the GPU, how many bytes this data will take up
        ParticleBuffer = new ComputeBuffer(numParticles, Particle.stride);

        // now get it to the GPU
        ParticleBuffer.SetData(particles);

        ArgsBuffer = new ComputeBuffer(5, 5* sizeof(uint), ComputeBufferType.IndirectArguments);
        ArgsBuffer.SetData(args);
    }

    /*
     * UpdateParticles()
     * 
     * TODO:
     * 1) Update compute shader parameters
     * 2) Execute compute shaders
     */

    void UpdateParticles()
    {

    }

    /*
     * RenderParticles()
     * 
     * TODO:
     * 1) Update material properties
     * 2) Draw mesh instanced indirect
     */
    void RenderParticles()
    {
        mat.SetBuffer("ParticleBuffer", ParticleBuffer);

        args[0] = mesh.GetIndexCount(0); // indicies per mesh
        args[1] = (uint)numParticles;

        ArgsBuffer.SetData(args);

        Graphics.DrawMeshInstancedIndirect(mesh, 0, mat, 
            new Bounds(Vector3.zero, new Vector3(100,100,100)), ArgsBuffer);

    }

    // Start is called before the first frame update
    void Start()
    {
        InitializeParticles();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
            InitializeParticles();

        UpdateParticles();
        RenderParticles();
    }
}
