using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Replacementshader : MonoBehaviour
{

    public Shader xRay;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.A))
        {
            GetComponent<Camera>().SetReplacementShader(xRay, "XRay");
            Debug.Log("A");
        }
        else if(Input.GetKeyDown(KeyCode.S))
        {
            GetComponent<Camera>().SetReplacementShader(xRay, "");
            Debug.Log("S");
        }
    }
}
