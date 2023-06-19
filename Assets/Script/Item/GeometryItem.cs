using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GeometryItem : ItemBase
{
    [SerializeField]
    private Shader _geometry = default;

    public override void Action()
    {
        FindObjectOfType<PlayerHitController>().Shader = EnemyController.ShaderType.GEOMETRY;
    }
}
