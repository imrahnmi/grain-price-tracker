import { useState, useEffect } from 'react'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
)

export default function AdminDashboard() {
  const [markets, setMarkets] = useState([])
  const [commodities, setCommodities] = useState([])
  const [prices, setPrices] = useState([])
  const [formData, setFormData] = useState({
    market_id: '',
    commodity_id: '',
    price: '',
    quality_grade: 'A'
  })

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    // Load markets
    const { data: marketsData } = await supabase
      .from('markets')
      .select('*')
      .order('name')
    setMarkets(marketsData || [])

    // Load commodities
    const { data: commoditiesData } = await supabase
      .from('commodities')
      .select('*')
      .order('name')
    setCommodities(commoditiesData || [])

    // Load recent prices
    const { data: pricesData } = await supabase
      .from('price_entries')
      .select(`
        *,
        markets(name),
        commodities(name)
      `)
      .order('created_at', { ascending: false })
      .limit(50)
    setPrices(pricesData || [])
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    
    const { error } = await supabase
      .from('price_entries')
      .insert([{
        market_id: parseInt(formData.market_id),
        commodity_id: parseInt(formData.commodity_id),
        price: parseFloat(formData.price),
        quality_grade: formData.quality_grade
      }])

    if (error) {
      alert('Error adding price: ' + error.message)
    } else {
      alert('Price added successfully!')
      setFormData({
        market_id: '',
        commodity_id: '',
        price: '',
        quality_grade: 'A'
      })
      loadData()
    }
  }

  return (
    <div style={{ padding: '20px', maxWidth: '1200px', margin: '0 auto' }}>
      <h1>Grain Price Tracker - Configuration Error</h1>
      
      {/* Add Price Form */}
      <div style={{ background: '#f5f5f5', padding: '20px', borderRadius: '8px', marginBottom: '30px' }}>
        <h2>Add Price Entry</h2>
        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: '15px' }}>
            <label>Market:</label>
            <select 
              value={formData.market_id} 
              onChange={e => setFormData({...formData, market_id: e.target.value})}
              required
              style={{ width: '100%', padding: '8px', marginTop: '5px' }}
            >
              <option value="">Select Market</option>
              {markets.map(market => (
                <option key={market.id} value={market.id}>
                  {market.name}
                </option>
              ))}
            </select>
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label>Commodity:</label>
            <select 
              value={formData.commodity_id} 
              onChange={e => setFormData({...formData, commodity_id: e.target.value})}
              required
              style={{ width: '100%', padding: '8px', marginTop: '5px' }}
            >
              <option value="">Select Commodity</option>
              {commodities.map(commodity => (
                <option key={commodity.id} value={commodity.id}>
                  {commodity.name}
                </option>
              ))}
            </select>
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label>Price (₦ per bag):</label>
            <input 
              type="number" 
              value={formData.price}
              onChange={e => setFormData({...formData, price: e.target.value})}
              required
              style={{ width: '100%', padding: '8px', marginTop: '5px' }}
              placeholder="Enter price"
            />
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label>Quality Grade:</label>
            <select 
              value={formData.quality_grade} 
              onChange={e => setFormData({...formData, quality_grade: e.target.value})}
              style={{ width: '100%', padding: '8px', marginTop: '5px' }}
            >
              <option value="A">Grade A</option>
              <option value="B">Grade B</option>
              <option value="C">Grade C</option>
            </select>
          </div>

          <button 
            type="submit"
            style={{
              background: '#2e7d32',
              color: 'white',
              padding: '10px 20px',
              border: 'none',
              borderRadius: '4px',
              cursor: 'pointer'
            }}
          >
            Add Price Entry
          </button>
        </form>
      </div>

      {/* Recent Prices */}
      <div>
        <h2>Recent Price Entries</h2>
        <div style={{ display: 'grid', gap: '10px' }}>
          {prices.map(price => (
            <div 
              key={price.id} 
              style={{
                background: 'white',
                padding: '15px',
                border: '1px solid #ddd',
                borderRadius: '4px'
              }}
            >
              <strong>{price.markets.name}</strong> - {price.commodities.name}
              <br />
              Price: ₦{price.price} per bag | Quality: {price.quality_grade}
              <br />
              <small>{new Date(price.created_at).toLocaleString()}</small>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}