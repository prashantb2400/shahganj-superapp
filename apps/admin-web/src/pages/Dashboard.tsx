import { 
  Users, 
  MapPin, 
  IndianRupee, 
  TrendingUp, 
  ShoppingBag,
  Activity
} from 'lucide-react';
import { 
  AreaChart, 
  Area, 
  XAxis, 
  YAxis, 
  Tooltip, 
  ResponsiveContainer 
} from 'recharts';

// Mock revenue data for local analytics tracking
const chartData = [
  { day: 'Mon', revenue: 4200 },
  { day: 'Tue', revenue: 5800 },
  { day: 'Wed', revenue: 8400 },
  { day: 'Thu', revenue: 7100 },
  { day: 'Fri', revenue: 9500 },
  { day: 'Sat', revenue: 12400 },
  { day: 'Sun', revenue: 14800 },
];

export default function Dashboard() {
  const stats = [
    { title: 'Total Active Users', value: '1,420', change: '+12.4%', icon: Users, color: 'text-blue-400' },
    { title: 'Vetted Merchants', value: '84', change: '+8.2%', icon: ShoppingBag, color: 'text-violet-400' },
    { title: 'Ongoing Ride Journeys', value: '38', change: '+22.5%', icon: Activity, color: 'text-emerald-400' },
    { title: 'Today\'s Platform Fees', value: '₹4,820', change: '+15.1%', icon: IndianRupee, color: 'text-purple-400' },
  ];

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Page Title */}
      <div>
        <h2 className="text-2xl font-bold text-white font-sans">Operational Overview</h2>
        <p className="text-sm text-slate-400 mt-1">Real-time statistics for the Shahganj rural digital logistics network.</p>
      </div>

      {/* KPI Grid */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        {stats.map((stat, idx) => {
          const Icon = stat.icon;
          return (
            <div key={idx} className="glass-panel p-6 rounded-2xl border border-slate-800/80 flex items-center justify-between">
              <div className="space-y-2">
                <span className="text-xs text-slate-500 font-bold uppercase tracking-wider">{stat.title}</span>
                <div className="flex items-baseline gap-2">
                  <span className="text-2xl font-bold text-white font-sans">{stat.value}</span>
                  <span className="text-xs font-semibold text-emerald-400">{stat.change}</span>
                </div>
              </div>
              <div className={`p-3 bg-slate-900/40 rounded-xl border border-slate-800 ${stat.color}`}>
                <Icon className="w-6 h-6" />
              </div>
            </div>
          );
        })}
      </div>

      {/* Core Dashboard Visuals */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Real-time Map Tracker Container */}
        <div className="lg:col-span-2 glass-panel rounded-2xl p-6 border border-slate-800/80 flex flex-col h-[400px]">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="font-bold text-slate-200">Active Rider tracking (GPS)</h3>
              <p className="text-xs text-slate-500">Live streams filtered every 3s via Dart Kalman smoother.</p>
            </div>
            <span className="px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-400 flex items-center gap-1.5">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
              <span>5 Riders Online</span>
            </span>
          </div>

          {/* Leaflet mock container area */}
          <div className="flex-1 bg-slate-950/60 rounded-xl relative overflow-hidden border border-slate-800/60 flex items-center justify-center">
            {/* Mock map graphic paths rendering */}
            <div className="absolute inset-0 bg-[#0c1328] opacity-40 bg-[linear-gradient(rgba(255,255,255,0.02)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.02)_1px,transparent_1px)] bg-[size:20px_20px]" />
            
            {/* Live coordinates pin representation indicators */}
            <div className="absolute top-[40%] left-[30%] flex flex-col items-center">
              <div className="bg-violet-600 text-[10px] font-bold text-white px-2 py-0.5 rounded shadow-lg border border-violet-400">Rider #1 (E-rickshaw)</div>
              <MapPin className="w-6 h-6 text-violet-500 animate-bounce" />
            </div>

            <div className="absolute top-[65%] left-[55%] flex flex-col items-center">
              <div className="bg-emerald-600 text-[10px] font-bold text-white px-2 py-0.5 rounded shadow-lg border border-emerald-400">Rider #4 (Food delivery)</div>
              <MapPin className="w-6 h-6 text-emerald-500" />
            </div>

            <div className="absolute top-[25%] left-[70%] flex flex-col items-center">
              <div className="bg-violet-600 text-[10px] font-bold text-white px-2 py-0.5 rounded shadow-lg border border-violet-400">Rider #2 (E-rickshaw)</div>
              <MapPin className="w-6 h-6 text-violet-500" />
            </div>

            <span className="absolute bottom-4 right-4 bg-slate-900/90 px-3 py-1.5 rounded-lg border border-slate-800 text-[11px] text-slate-400">
              Center: <span className="font-mono text-slate-300">26.0592° N, 82.6865° E (Shahganj)</span>
            </span>
          </div>
        </div>

        {/* Platform Revenue Graphic using Recharts */}
        <div className="glass-panel rounded-2xl p-6 border border-slate-800/80 flex flex-col h-[400px]">
          <div className="mb-6">
            <h3 className="font-bold text-slate-200">Revenue Stream Analysis</h3>
            <p className="text-xs text-slate-500">Weekly aggregate transaction shares (₹ INR).</p>
          </div>

          <div className="flex-1 min-h-[200px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={chartData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#7C3AED" stopOpacity={0.4}/>
                    <stop offset="95%" stopColor="#7C3AED" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <XAxis dataKey="day" stroke="#475569" fontSize={11} tickLine={false} />
                <YAxis stroke="#475569" fontSize={11} tickLine={false} />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#1e293b', border: '1px solid #334155', borderRadius: '10px' }}
                  labelStyle={{ color: '#94a3b8', fontSize: '11px', fontWeight: 'bold' }}
                />
                <Area type="monotone" dataKey="revenue" stroke="#a855f7" strokeWidth={2} fillOpacity={1} fill="url(#colorRevenue)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>

          <div className="border-t border-slate-800/60 pt-4 flex items-center justify-between text-xs text-slate-400">
            <span>Average Order Value: <strong className="text-white">₹160</strong></span>
            <span className="flex items-center gap-1 text-emerald-400">
              <TrendingUp className="w-3.5 h-3.5" /> +15.4% vs last week
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}
