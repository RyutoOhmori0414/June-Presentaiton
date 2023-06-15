using System.Collections.Generic;
using UnityEngine;
using System;

[Serializable]
public class SkillBase
{
    /// <summary>アイテムのトレード方法</summary>
    [SerializeField]
    private TradeType _tradeType;

    public TradeType TradeTyoe => _tradeType;

    /// <summary>Item名を設定</summary>
    [SerializeField]
    private string _skillName;

    public string ItemName => _skillName;

    /// <summary>購入時に必要なアイテム</summary>
    [SerializeField]
    private List<string> _requiredItems = new();
    public List<string> GetRequiredItems => _requiredItems;
    /// <summary>購入に必要な金額</summary>
    [SerializeField]
    private int _price;
    public int Price => _price;

    SkillBase(string skillName, int price, TradeType tradeType = TradeType.money)
    {
        this._skillName = skillName;
        this._price = price;
        this._tradeType = tradeType;
    }

    /// <summary>スキルのEffectの処理</summary>
    public virtual void SkillEffect()
    {

    }

    /// <summary>金を使用した購入</summary>
    /// <param name="playerBalance">現在の残高</param>
    /// <returns>交換可能かどうか</returns>
    public bool Condition(int playerBalance)
    {
        if (playerBalance >= _price)
        {//Playerの金が足りたらtrue,足りなかったらfalse
            return true;
        }
        else
        {
            return false;
        }
    }

    /// <summary>物の交換</summary>
    /// <param name="plyerItems">所持品</param>
    /// <returns>交換可能かどうか</returns>
    public bool Condition(List<string> plyerItems)　//購入可能かの判定
    {
        var tempList = new List<string>(plyerItems);
        for (int i = 0; i < _requiredItems.Count; i++) //購入に必要なアイテムの分ループ
        {
            if (!tempList.Contains(_requiredItems[i]))
            {//必要なアイテムが一つでもなかったとき、Falseを返してループを終了
                return false;
            }
            else
            {//必要なアイテムがあったときにコピーしたリストからリムーブして次の判定
                tempList.RemoveAt(tempList.IndexOf(_requiredItems[i]));
            }
        }
        return true;
    }

}

