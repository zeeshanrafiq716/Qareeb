import React, { useState, useEffect } from 'react'
import {
  ShieldAlert,
  Search,
  CheckCircle2,
  Clock,
  Phone,
  User,
  Calendar,
  Filter,
  Check,
  RefreshCw,
  MessageSquare,
  AlertCircle,
  ExternalLink,
} from 'lucide-react'
import { fetchReportsApi, fetchReportsStatsApi, patchReportStatusApi } from '../api/admin'

export function ReportsComplaintsView() {
  const [reports, setReports] = useState([])
  const [stats, setStats] = useState({ open: 0, resolved: 0, total: 0 })
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState('all') // 'all', 'open', 'resolved'
  const [selectedReport, setSelectedReport] = useState(null)
  const [actionLoading, setActionLoading] = useState(false)

  const loadData = async () => {
    try {
      const [reportsData, statsData] = await Promise.all([
        fetchReportsApi(statusFilter !== 'all' ? { status: statusFilter } : {}),
        fetchReportsStatsApi(),
      ])
      setReports(reportsData || [])
      setStats(statsData || { open: 0, resolved: 0, total: 0 })
    } catch (err) {
      console.error('Error loading reports:', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadData()
    const interval = setInterval(loadData, 4000)
    return () => clearInterval(interval)
  }, [statusFilter])

  const handleToggleStatus = async (report) => {
    const nextStatus = report.status === 'open' ? 'resolved' : 'open'
    try {
      setActionLoading(true)
      await patchReportStatusApi(report.id, { status: nextStatus })
      await loadData()
      if (selectedReport && selectedReport.id === report.id) {
        setSelectedReport({ ...selectedReport, status: nextStatus })
      }
    } catch (err) {
      console.error('Error updating status:', err)
    } finally {
      setActionLoading(false)
    }
  }

  const filteredReports = reports.filter((r) => {
    const q = searchQuery.toLowerCase()
    return (
      (r.ticket_number && r.ticket_number.toLowerCase().includes(q)) ||
      (r.category && r.category.toLowerCase().includes(q)) ||
      (r.description && r.description.toLowerCase().includes(q)) ||
      (r.customer_phone && r.customer_phone.includes(q)) ||
      (r.customer_name && r.customer_name.toLowerCase().includes(q))
    )
  })

  return (
    <div className="flex flex-col gap-5 w-full max-w-[1084px] mx-auto select-none pb-12">
      {/* ===== TOP METRICS SECTION ===== */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* Metric 1: Open Reports */}
        <div
          onClick={() => setStatusFilter('open')}
          className={`bg-white rounded-[20px] p-5 border cursor-pointer transition-all ${
            statusFilter === 'open'
              ? 'border-[#EF4444] shadow-md ring-2 ring-[#EF4444]/20'
              : 'border-[#EBEBEB] hover:border-[#DECFFC]'
          }`}
        >
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-[#616166] uppercase tracking-wider">
              Open Dispute Reports
            </span>
            <div className="w-8 h-8 rounded-lg bg-[#FEF2F2] flex items-center justify-center text-[#EF4444]">
              <ShieldAlert className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-3 flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-[#1C2926] tracking-tight">
              {stats.open}
            </span>
            <span className="text-xs font-medium text-[#EF4444]">Needs Action</span>
          </div>
        </div>

        {/* Metric 2: Resolved Reports */}
        <div
          onClick={() => setStatusFilter('resolved')}
          className={`bg-white rounded-[20px] p-5 border cursor-pointer transition-all ${
            statusFilter === 'resolved'
              ? 'border-[#10B981] shadow-md ring-2 ring-[#10B981]/20'
              : 'border-[#EBEBEB] hover:border-[#DECFFC]'
          }`}
        >
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-[#616166] uppercase tracking-wider">
              Resolved Cases
            </span>
            <div className="w-8 h-8 rounded-lg bg-[#ECFDF5] flex items-center justify-center text-[#10B981]">
              <CheckCircle2 className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-3 flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-[#1C2926] tracking-tight">
              {stats.resolved}
            </span>
            <span className="text-xs font-medium text-[#10B981]">Completed</span>
          </div>
        </div>

        {/* Metric 3: Total Tickets */}
        <div
          onClick={() => setStatusFilter('all')}
          className={`bg-white rounded-[20px] p-5 border cursor-pointer transition-all ${
            statusFilter === 'all'
              ? 'border-[#8B53FE] shadow-md ring-2 ring-[#8B53FE]/20'
              : 'border-[#EBEBEB] hover:border-[#DECFFC]'
          }`}
        >
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-[#616166] uppercase tracking-wider">
              Total Support Inquiries
            </span>
            <div className="w-8 h-8 rounded-lg bg-[#F5F0FF] flex items-center justify-center text-[#8B53FE]">
              <MessageSquare className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-3 flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-[#1C2926] tracking-tight">
              {stats.total}
            </span>
            <span className="text-xs font-medium text-[#8B53FE]">All Time</span>
          </div>
        </div>
      </div>

      {/* ===== FILTER BAR & SEARCH ===== */}
      <div className="bg-white rounded-[20px] p-4 border border-[#EBEBEB] flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-2">
          {['all', 'open', 'resolved'].map((filter) => (
            <button
              key={filter}
              type="button"
              onClick={() => setStatusFilter(filter)}
              className={`px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-all capitalize ${
                statusFilter === filter
                  ? 'bg-[#8B53FE] text-white shadow-sm'
                  : 'bg-[#F9FAFB] text-[#616166] hover:bg-[#F3F4F6]'
              }`}
            >
              {filter === 'all' ? 'All Reports' : filter}
            </button>
          ))}
        </div>

        <div className="relative flex-1 max-w-sm min-w-[220px]">
          <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-[#9EAFA9]" />
          <input
            type="text"
            placeholder="Search by ticket #, category, phone..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-9 pr-4 py-2 bg-[#F9FAFB] border border-[#EBEBEB] rounded-xl text-xs text-[#1C2926] placeholder-[#9EAFA9] focus:outline-none focus:border-[#8B53FE]"
          />
        </div>
      </div>

      {/* ===== REPORTS TABLE / LIST ===== */}
      <div className="bg-white rounded-[20px] border border-[#EBEBEB] shadow-xs overflow-hidden">
        <div className="px-5 py-4 border-b border-[#F2F2F2] flex items-center justify-between">
          <h3 className="text-[16px] font-bold text-[#1C2926]">
            Customer Feedback & Support Tickets ({filteredReports.length})
          </h3>
          <button
            type="button"
            onClick={loadData}
            className="text-xs font-medium text-[#8B53FE] hover:underline flex items-center gap-1.5"
          >
            <RefreshCw className="w-3.5 h-3.5" />
            <span>Refresh</span>
          </button>
        </div>

        {loading ? (
          <div className="py-16 text-center text-xs text-[#9EAFA9]">Loading reports...</div>
        ) : filteredReports.length === 0 ? (
          <div className="py-16 flex flex-col items-center justify-center text-center text-[#9EAFA9]">
            <ShieldAlert className="w-10 h-10 mb-2 text-[#DECFFC]" />
            <p className="text-sm font-semibold text-[#1C2926]">No reports found</p>
            <p className="text-xs text-[#616166] mt-1">
              Customer issue reports and complaints submitted from the mobile app will show up here.
            </p>
          </div>
        ) : (
          <div className="divide-y divide-[#F2F2F2]">
            {filteredReports.map((report) => {
              const isResolved = report.status === 'resolved'
              const formattedDate = new Date(report.created_at).toLocaleString('en-US', {
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
              })

              return (
                <div
                  key={report.id}
                  className="p-4 hover:bg-[#FAF9FF] transition-all flex flex-col sm:flex-row sm:items-center justify-between gap-3"
                >
                  <div className="flex items-start gap-3 min-w-0 flex-1">
                    <div
                      className={`w-9 h-9 rounded-xl shrink-0 flex items-center justify-center mt-0.5 ${
                        isResolved
                          ? 'bg-[#ECFDF5] text-[#10B981]'
                          : 'bg-[#FEF2F2] text-[#EF4444]'
                      }`}
                    >
                      {isResolved ? (
                        <CheckCircle2 className="w-5 h-5" />
                      ) : (
                        <AlertCircle className="w-5 h-5" />
                      )}
                    </div>

                    <div className="flex flex-col min-w-0 flex-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <span className="text-xs font-bold text-[#8B53FE] font-mono">
                          {report.ticket_number}
                        </span>
                        <span className="text-[13px] font-bold text-[#1C2926]">
                          {report.category}
                        </span>
                        <span
                          className={`text-[10px] font-semibold px-2 py-0.5 rounded-full uppercase tracking-wider ${
                            isResolved
                              ? 'bg-[#ECFDF5] text-[#059669]'
                              : 'bg-[#FEE2E2] text-[#DC2626]'
                          }`}
                        >
                          {report.status}
                        </span>
                      </div>

                      <p className="text-xs text-[#4B5563] mt-1 line-clamp-2 leading-relaxed">
                        {report.description}
                      </p>

                      <div className="flex items-center gap-4 mt-2 text-[11px] text-[#616166] flex-wrap">
                        {report.customer_phone && (
                          <span className="flex items-center gap-1 font-mono">
                            <Phone className="w-3 h-3 text-[#9EAFA9]" />
                            {report.customer_phone}
                          </span>
                        )}
                        {report.customer_name && (
                          <span className="flex items-center gap-1">
                            <User className="w-3 h-3 text-[#9EAFA9]" />
                            {report.customer_name}
                          </span>
                        )}
                        <span className="flex items-center gap-1">
                          <Calendar className="w-3 h-3 text-[#9EAFA9]" />
                          {formattedDate}
                        </span>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 shrink-0 self-end sm:self-center">
                    <button
                      type="button"
                      disabled={actionLoading}
                      onClick={() => handleToggleStatus(report)}
                      className={`px-3 py-1.5 rounded-xl text-xs font-semibold flex items-center gap-1.5 transition-all ${
                        isResolved
                          ? 'bg-[#F3F4F6] text-[#616166] hover:bg-[#E5E7EB]'
                          : 'bg-[#10B981] text-white hover:bg-[#059669] shadow-xs'
                      }`}
                    >
                      <Check className="w-3.5 h-3.5" />
                      <span>{isResolved ? 'Mark Open' : 'Resolve'}</span>
                    </button>

                    <button
                      type="button"
                      onClick={() => setSelectedReport(report)}
                      className="px-3 py-1.5 rounded-xl text-xs font-semibold text-[#8B53FE] bg-[#F5F0FF] hover:bg-[#EBDDFF] transition-all"
                    >
                      View Details
                    </button>
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </div>

      {/* ===== REPORT DETAIL MODAL ===== */}
      {selectedReport && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] max-w-lg w-full p-6 shadow-2xl flex flex-col gap-4 border border-[#EBEBEB]">
            <div className="flex items-center justify-between pb-3 border-b border-[#F2F2F2]">
              <div>
                <span className="text-xs font-mono font-bold text-[#8B53FE]">
                  {selectedReport.ticket_number}
                </span>
                <h4 className="text-base font-bold text-[#1C2926] mt-0.5">
                  {selectedReport.category}
                </h4>
              </div>
              <span
                className={`text-xs font-semibold px-2.5 py-1 rounded-full uppercase tracking-wider ${
                  selectedReport.status === 'resolved'
                    ? 'bg-[#ECFDF5] text-[#059669]'
                    : 'bg-[#FEE2E2] text-[#DC2626]'
                }`}
              >
                {selectedReport.status}
              </span>
            </div>

            <div className="flex flex-col gap-3 text-xs text-[#4B5563]">
              <div>
                <span className="font-semibold text-[#1C2926] block mb-1">Issue Description:</span>
                <div className="p-3 bg-[#F9FAFB] rounded-xl border border-[#E5E7EB] text-[#1C2926] whitespace-pre-wrap leading-relaxed">
                  {selectedReport.description}
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3 pt-2">
                <div>
                  <span className="font-semibold text-[#616166] block">Customer Phone:</span>
                  <span className="font-mono text-[#1C2926] font-medium">
                    {selectedReport.customer_phone || 'Not Provided'}
                  </span>
                </div>
                <div>
                  <span className="font-semibold text-[#616166] block">Customer Name:</span>
                  <span className="text-[#1C2926] font-medium">
                    {selectedReport.customer_name || 'Guest User'}
                  </span>
                </div>
                <div>
                  <span className="font-semibold text-[#616166] block">Submitted At:</span>
                  <span className="text-[#1C2926]">
                    {new Date(selectedReport.created_at).toLocaleString()}
                  </span>
                </div>
                <div>
                  <span className="font-semibold text-[#616166] block">Platform Source:</span>
                  <span className="text-[#1C2926] capitalize">
                    {selectedReport.source || 'Customer App'}
                  </span>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-end gap-2 pt-3 border-t border-[#F2F2F2]">
              <button
                type="button"
                onClick={() => setSelectedReport(null)}
                className="px-4 py-2 rounded-xl text-xs font-semibold text-[#616166] hover:bg-[#F3F4F6]"
              >
                Close
              </button>
              <button
                type="button"
                disabled={actionLoading}
                onClick={() => handleToggleStatus(selectedReport)}
                className={`px-4 py-2 rounded-xl text-xs font-semibold flex items-center gap-1.5 text-white ${
                  selectedReport.status === 'resolved'
                    ? 'bg-[#616166] hover:bg-[#4B5563]'
                    : 'bg-[#10B981] hover:bg-[#059669]'
                }`}
              >
                <Check className="w-3.5 h-3.5" />
                <span>
                  {selectedReport.status === 'resolved' ? 'Re-open Ticket' : 'Mark as Resolved'}
                </span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default ReportsComplaintsView

