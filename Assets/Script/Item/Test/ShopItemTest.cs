using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShopItemTest : ItemBase
{
    public override void Action()
    {
        Debug.Log("購入されたアイテムです");
    }
}
